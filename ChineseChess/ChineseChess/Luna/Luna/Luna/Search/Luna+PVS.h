//
//  Luna+PVS.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Hash.h"
#import "Luna+Killer.h"

#import "Luna+Generate.h"
#import "Luna+Heuristic.h"

#import "Luna+Evaluate.h"

typedef struct {
    LCMutablePositionRef position;
    
    LCMutableHashHeuristicRef hashTable;
    LCMutableKillerMoveRef killerLayers;
    
    LCMutableMovesTrackRef moveLayers;
    LCMutableHistoryTrackRef historyTable;
    
    LCMutableEvaluateRef evaluate;
    LCMutableHashHeuristicIORef io;
    
    const Bool *isThinking;
    LCDepth rootSearchDepth;
} LCNextStep;

typedef const LCNextStep *const LCNextStepRef;
typedef LCNextStep *const LCMutableNextStepRef;

// MARK: - LCNextStep Life Cycle
extern void LCNextStepAlloc(LCMutableNextStepRef nextStep);

extern void LCNextStepInit(LCMutableNextStepRef nextStep, Bool *isThinking, LCDepth rootSearchDepth);

extern void LCNextStepDealloc(LCNextStepRef nextStep);

// MARK: - Search
extern void LCNextStepSearch(LCNextStepRef nextStep, void (^ block)(float, UInt16));
