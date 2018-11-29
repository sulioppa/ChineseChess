//
//  Luna+NextStep.m
//  Luna
//
//  Created by 李夙璃 on 2018/11/23.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+NextStep.h"
#import "Luna+PVS.h"

@interface LunaNextStep() {
    LCNextStep _nextStep;
}
@end

@implementation LunaNextStep

- (instancetype)init
{
    if (self = [super init]) {
        LCNextStepAlloc(&_nextStep);
    }
    
    return self;
}

- (void)dealloc
{
    LCNextStepDealloc(&_nextStep);
}

- (void)nextStepWithFEN:(NSString *)FEN
             targetSide:(BOOL)side
            searchDepth:(int)depth
            bannedMoves:(NSArray<NSNumber *> *)bannedMoves
             isThinking:(BOOL *)isThinking
                  block:(void (^)(float, UInt16))block
{
    LCNextStepInit(&_nextStep, (Bool *)isThinking, depth);
    LCNextStepSearch(&_nextStep, block);
}

@end

