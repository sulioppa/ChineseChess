//
//  Luna+NextStep.h
//  Luna
//
//  Created by 李夙璃 on 2018/11/23.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN

@interface LunaNextStep : NSObject

+ (NSArray<NSNumber *> *)legalMovesWithFEN:(NSString *)FEN
                              targetSide:(BOOL)side
                                location:(UInt8)location;

// Prepare before dispatching work so cancellation also invalidates queued searches.
- (uint64_t)prepareSearch;
- (void)cancelSearch;
- (BOOL)isSearchCurrent:(uint64_t)requestID;

- (void)nextStepWithFEN:(NSString *)FEN
             targetSide:(BOOL)side
            searchDepth:(int)depth
            bannedMoves:(NSArray<NSNumber *> *)bannedMoves
              requestID:(uint64_t)requestID
                  block:(void (^)(float progress, UInt16 move))block;

@end

NS_ASSUME_NONNULL_END
