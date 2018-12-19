//
//  Luna+PVS.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PVS.h"
#import "Luna+PositionChanged.h"

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
    nextStep->rootDepth = rootDepth > LCSearchMaxDepth ? LCSearchMaxDepth : rootDepth;
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
    LCMutableMovesArrayRef moves = nextStep->movesLayers;
    LCMutablePositionRef position = nextStep->position;
    
    // 吃子着法
    LCMovesArrayPopAll(moves);
    LCGenerateSortedEatMoves(position, moves);
    
    // 不吃子着法
    moves->bottom = moves->top;
    LCGenerateSortedNonEatMoves(position, nextStep->historyTable, moves);
    
    // 合理过滤
    LCMove onlyMove = 0;
    UInt8 countOfMoves = 0;
    
    moves->bottom = moves->moves;
    for (moves->move = moves->bottom; moves->move < moves->top; moves->move++) {
        if (LCPositionIsLegalIfChangedByMove(position, moves->move, &(moves->buffer))) {
            onlyMove = *(moves->move);
            countOfMoves++;
        } else {
            *(moves->move) = 0;
        }
    }
    
    // 唯一着法
    if (countOfMoves <= 1) {
        block(1.0, onlyMove);
        return;
    }
    
    // 过滤禁着, onlyMove为某一合理着法
    countOfMoves = 0;
    
    for (moves->move = moves->bottom; moves->move < moves->top; moves->move++) {
        if (*(moves->move) == 0) {
            continue;
        }
        
        if (LCMoveExistDetailGetMoveExist(nextStep->detail, *(moves->move), 0)) {
            *(moves->move) = 0;
        } else {
            onlyMove = *(moves->move);
            countOfMoves++;
        }
    }
    
    // 唯一着法
    if (countOfMoves <= 1) {
        block(1.0, onlyMove);
        return;
    }
    
    // 调整次序，hash, eat, killer, non eat.
    block(1.0, onlyMove);
}
