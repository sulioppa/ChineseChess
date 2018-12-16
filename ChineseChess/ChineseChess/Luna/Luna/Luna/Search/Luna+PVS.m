//
//  Luna+PVS.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PVS.h"

// MARK: - LCNextStep Life Cycle
void LCNextStepAlloc(LCMutableNextStepRef nextStep) {
    *nextStep = (LCNextStep) {
        .position = LCPositionCreateMutable(),
        
        .hashTable = LCHashHeuristicCreateMutable(),
        .killerLayers = LCKillerMoveCreateMutable(),
        
        .moveLayers = LCMovesTrackCreateMutable(),
        .historyTable = LCHistoryTrackCreateMutable(),
        
        .evaluate = LCEvaluateCreateMutable(),
        
        .io = LCHashHeuristicIOCreateMutable(),
        .hash = LCPositionHashCreateMutable(),
        .detail = LCMoveExistDetailCreateMutable(),
        
        .isThinking = NULL,
        .rootSearchDepth = 0
    };
}

void LCNextStepInit(LCMutableNextStepRef nextStep, Bool *isThinking, LCDepth rootSearchDepth) {
    nextStep->isThinking = isThinking;
    nextStep->rootSearchDepth = rootSearchDepth;
}

void LCNextStepDealloc(LCNextStepRef nextStep) {
    LCMoveExistDetailRelease(nextStep->detail);
    LCPositionHashRelease(nextStep->hash);
    LCHashHeuristicIORelease(nextStep->io);
    
    LCEvaluateRelease(nextStep->evaluate);
    
    LCHistoryTrackRelease(nextStep->historyTable);
    LCMovesTrackRelease(nextStep->moveLayers);
    
    LCKillerMoveRelease(nextStep->killerLayers);
    LCHashHeuristicRelease(nextStep->hashTable);
    
    LCPositionRelease(nextStep->position);
}

// MARK: - PVS
void LCNextStepSearch(LCNextStepRef nextStep, void (^ block)(float, UInt16)) {
    
}
