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
        .evaluate = LCEvaluateCreateMutable(),
        
        .hashTable = LCHashHeuristicCreateMutable(),
        .historyTable = LCHistoryTrackCreateMutable(),
        
        .io = LCHashHeuristicIOCreateMutable(),
        .hash = LCPositionHashCreateMutable(),
        
        .detail = LCMoveExistDetailCreateMutable(),
        .killersLayers = LCKillerMoveCreateMutable(),
        .movesLayers = LCMovesArrayCreateMutable(),
        
        .isThinking = NULL,
        .rootDepth = 0
    };
}

void LCNextStepInit(LCMutableNextStepRef nextStep, Bool *isThinking, LCDepth rootDepth) {
    nextStep->isThinking = isThinking;
    nextStep->rootDepth = rootDepth;
}

void LCNextStepDealloc(LCNextStepRef nextStep) {
    LCMovesArrayRelease(nextStep->movesLayers);
    LCKillerMoveRelease(nextStep->killersLayers);
    LCMoveExistDetailRelease(nextStep->detail);
    
    LCPositionHashRelease(nextStep->hash);
    LCHashHeuristicIORelease(nextStep->io);
    
    LCHistoryTrackRelease(nextStep->historyTable);
    LCHashHeuristicRelease(nextStep->hashTable);
    
    LCEvaluateRelease(nextStep->evaluate);
    LCPositionRelease(nextStep->position);
}

// MARK: - PVS
void LCNextStepSearch(LCNextStepRef nextStep, void (^ block)(float, UInt16)) {
    
}
