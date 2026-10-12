//
//  Luna+NextStep.mm
//  Luna
//
//  Created by 李夙璃 on 2018/11/23.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+NextStep.h"
#import "../../../Pikafish/Bridge/LunaPikafish.h"

#include <algorithm>
#include <atomic>
#include <vector>

@interface LunaNextStep() {
    LPFEngine *_engine;
    NSLock *_searchLock;
    std::atomic<uint64_t> _generation;
}
@end

namespace {

struct SearchContext {
    __unsafe_unretained LunaNextStep *owner;
    uint64_t requestID;
    __unsafe_unretained void (^block)(float, UInt16);
};

int ShouldStop(void *opaque) {
    auto &context = *static_cast<SearchContext *>(opaque);
    return ![context.owner isSearchCurrent:context.requestID];
}

void ReportProgress(float progress, uint16_t, void *opaque) {
    auto &context = *static_cast<SearchContext *>(opaque);
    if ([context.owner isSearchCurrent:context.requestID]) {
        // A PV candidate is not a completed answer; the UI plays nonzero moves.
        context.block(std::min(progress, 0.99f), 0);
    }
}

} // namespace

@implementation LunaNextStep

- (instancetype)init
{
    if ((self = [super init])) {
        _engine = nullptr;
        _searchLock = [NSLock new];
        _generation.store(0);
    }
    return self;
}

- (void)dealloc
{
    lpf_engine_destroy(_engine);
}

+ (NSArray<NSNumber *> *)legalMovesWithFEN:(NSString *)FEN
                              targetSide:(BOOL)side
                                location:(UInt8)location
{
    // Move highlighting must not load the neural network or start a search.
    char error[256] = {};
    size_t count = lpf_legal_moves(FEN.UTF8String, side, nullptr, 0, error, sizeof(error));
    if (error[0]) {
        NSLog(@"Pikafish legal moves: %s", error);
        return @[];
    }

    std::vector<uint16_t> allMoves(count);
    count = lpf_legal_moves(FEN.UTF8String, side, allMoves.data(), allMoves.size(), error, sizeof(error));
    if (error[0]) {
        NSLog(@"Pikafish legal moves: %s", error);
        return @[];
    }

    NSMutableArray<NSNumber *> *destinations = [NSMutableArray array];
    for (size_t index = 0; index < std::min(count, allMoves.size()); ++index) {
        uint16_t move = allMoves[index];
        if ((move >> 8) == location) {
            [destinations addObject:@(move & 0xff)];
        }
    }
    return [destinations copy];
}

- (uint64_t)prepareSearch {
    return _generation.fetch_add(1) + 1;
}

- (void)cancelSearch {
    // Never take the search lock on the UI thread; a search may be holding it.
    _generation.fetch_add(1);
}

- (BOOL)isSearchCurrent:(uint64_t)requestID {
    return _generation.load() == requestID;
}

- (void)nextStepWithFEN:(NSString *)FEN
             targetSide:(BOOL)side
            searchDepth:(int)depth
            bannedMoves:(NSArray<NSNumber *> *)bannedMoves
              requestID:(uint64_t)requestID
                  block:(void (^)(float, UInt16))block
{
    [_searchLock lock];
    @try {
        if (![self isSearchCurrent:requestID]) {
            return;
        }

        char error[256] = {};
        if (!_engine) {
            NSBundle *bundle = [NSBundle bundleForClass:[LunaNextStep class]];
            NSString *modelPath = [bundle pathForResource:@"pikafish" ofType:@"nnue"];
            if (!modelPath) {
                modelPath = [[NSBundle mainBundle] pathForResource:@"pikafish" ofType:@"nnue"];
            }
            if (modelPath) {
                _engine = lpf_engine_create(modelPath.fileSystemRepresentation, error, sizeof(error));
            } else {
                NSLog(@"Pikafish: bundled pikafish.nnue was not found.");
            }
            if (!_engine) {
                if (error[0]) {
                    NSLog(@"Pikafish initialization: %s", error);
                }
                if ([self isSearchCurrent:requestID]) {
                    block(1.0f, 0);
                }
                return;
            }
        }

        if (![self isSearchCurrent:requestID]) {
            return;
        }

        std::vector<uint16_t> banned;
        banned.reserve(bannedMoves.count);
        for (NSNumber *move in bannedMoves) {
            banned.push_back(move.unsignedShortValue);
        }

        // Keep the existing level API and search to its depth without a time
        // limit. A hint for a human player (level 0) uses the minimum AI level.
        int searchDepth = std::clamp(depth, 4, 14);
        SearchContext context = {self, requestID, block};
        uint16_t move = lpf_search(_engine, FEN.UTF8String, side, searchDepth, 0,
                                   banned.data(), banned.size(), ShouldStop, ReportProgress,
                                   &context, error, sizeof(error));
        if (error[0]) {
            NSLog(@"Pikafish search: %s", error);
        }
        if ([self isSearchCurrent:requestID]) {
            block(1.0f, move);
        }
    } @finally {
        [_searchLock unlock];
    }
}

@end
