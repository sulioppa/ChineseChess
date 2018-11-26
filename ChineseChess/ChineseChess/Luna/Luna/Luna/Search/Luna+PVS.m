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
        
        .isThinking = NULL,
        .searchDepth = 0
    };
}

void LCNextStepInit(LCMutableNextStepRef nextStep, Bool *isThinking, LCDepth searchDepth) {
    nextStep->isThinking = isThinking;
    nextStep->searchDepth = searchDepth;
}

void LCNextStepDealloc(LCNextStepRef nextStep) {
    LCEvaluateRelease(nextStep->evaluate);
    
    LCHistoryTrackRelease(nextStep->historyTable);
    LCMovesTrackRelease(nextStep->moveLayers);
    
    LCKillerMoveRelease(nextStep->killerLayers);
    LCHashHeuristicRelease(nextStep->hashTable);
    
    LCPositionRelease(nextStep->position);
}

// MARK: - PVS
void LCPrincipalVariationSearch() {
    
}
