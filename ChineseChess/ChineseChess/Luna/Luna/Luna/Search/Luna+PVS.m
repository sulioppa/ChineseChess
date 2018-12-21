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
        .killersLayers = LCKillerMovesCreateMutable(),
        .historyTable = LCHistoryTrackCreateMutable(),
        
        .movesLayers = LCMovesArrayCreateMutable(),
        .io = LCHashHeuristicIOCreateMutable(),
        
        .hash = LCPositionHashCreateMutable(),
        .detail = LCMoveExistDetailCreateMutable(),
        
        .isThinking = NULL,
        .rootDepth = 0
    };
}

void LCNextStepInit(LCMutableNextStepRef nextStep, Bool *isThinking, LCDepth rootDepth) {
    nextStep->isThinking = isThinking;
    nextStep->rootDepth = rootDepth > LCSearchMaxDepth ? LCSearchMaxDepth : rootDepth;
}

void LCNextStepDealloc(LCNextStepRef nextStep) {
    LCMoveExistDetailRelease(nextStep->detail);
    LCPositionHashRelease(nextStep->hash);
    
    LCHashHeuristicIORelease(nextStep->io);
    LCMovesArrayRelease(nextStep->movesLayers);
    
    LCHistoryTrackRelease(nextStep->historyTable);
    LCKillerMovesRelease(nextStep->killersLayers);
    LCHashHeuristicRelease(nextStep->hashTable);
    
    LCEvaluateRelease(nextStep->evaluate);
    LCPositionRelease(nextStep->position);
}

// MARK: - PVS
Int16 _LCPVSSearch(LCNextStepRef nextStep, Int16 alpha, Int16 beta, UInt8 distance) {
    return 0;
}

// MARK: - Root Search
void LCNextStepSearch(LCNextStepRef nextStep, void (^ block)(float, UInt16)) {
    LCMutableMovesArrayRef moves = nextStep->movesLayers;
    LCMutablePositionRef position = nextStep->position;
    
    // 着法生成
    LCMovesArrayPopAll(moves);
    LCGenerateSortedEatMoves(position, moves);
    
    LCMovesArrayResetBottom(moves, true);
    LCGenerateSortedNonEatMoves(position, nextStep->historyTable, moves);
    LCMovesArrayResetBottom(moves, false);
    
    // 合理过滤
    __block LCMove onlyMove = 0;
    __block UInt8 countOfMoves = 0;
    
    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMove *const move, Bool *const stop) {
        if (LCPositionIsLegalIfChangedByMove(position, move, &(moves->buffer))) {
            onlyMove = *move;
            countOfMoves++;
        } else {
            *move = 0;
        }
    });
    
    if (countOfMoves <= 1) {
        block(1.0, onlyMove);
        return;
    }
    
    // 过滤禁着
    countOfMoves = 0;
    
    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMove *const move, Bool *const stop) {
        if (*move == 0) {
            return;
        }
        
        if (LCMoveExistDetailGetMoveExist(nextStep->detail, *move, 0)) {
            *move = 0;
        } else {
            onlyMove = *move;
            countOfMoves++;
        }
    });
    
    if (countOfMoves <= 1) {
        block(1.0, onlyMove);
        return;
    }
    
    // 调整次序，hash, killers, eat, non eat.
    LCHashHeuristicIOBeginRead(nextStep->io, 0, nextStep->rootDepth, -LCPositionCheckMateValue, LCPositionCheckMateValue);
    LCHashHeuristicRead(nextStep->hashTable, position, nextStep->io);
    
    if (nextStep->io->type == LCHashHeuristicTypeValue) {
        onlyMove = LCHashHeuristicReadMove(nextStep->hashTable, position);
        
        if (nextStep->io->value >= LCPositionCheckMateValue - 1) {
            block(1.0, onlyMove);
            return;
        }
    } else if (nextStep->io->type == LCHashHeuristicTypeMove) {
        onlyMove = nextStep->io->move;
    } else {
        onlyMove = 0;
    }
    
    // 最终的着法次序
    LCMovesArray movesArray;
    LCMutableMovesArrayRef array = &movesArray;
    
    LCMovesArrayPopAll(array);
    
    if (LCMovesArrayClearMove(moves, &onlyMove)) {
        LCMovesArrayPushBack(array, onlyMove);
    }
    
    LCKillerMovesEnumerateMovesUsingBlock(nextStep->killersLayers, ^(const LCMove *const move, Bool *const stop) {
        if (LCMovesArrayClearMove(moves, move)) {
            LCMovesArrayPushBack(array, *move);
        }
    });

    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMove *const move, Bool *const stop) {
        if (*move) {
            LCMovesArrayPushBack(array, *move);
        }
    });
    
    *moves = *array;
    
    // Begin PVS Search
    LCEvaluateInit(nextStep->evaluate, position);
    
    LCHashHeuristicClear(nextStep->hashTable);
    LCKillerMovesClear(nextStep->killersLayers);
    LCHistoryTrackClear(nextStep->historyTable);
    
    LCPositionHashClear(nextStep->hash);
    LCMoveExistDetailClear(nextStep->detail);
    
    // Set Position Hash
    LCPositionHashSetPosition(nextStep->hash, position);
    LCSideRevese(&(position->side));
    
    float progress = 0.0;
    LCMove bestmove = 0;
    
    Int16 value;
    Int16 alpha = -LCPositionCheckMateValue;

    for (moves->move = moves->bottom; moves->move < moves->top; moves->move++) {
        if (!*(nextStep->isThinking)) {
            return;
        }
        
        // PVS
        LCPositionChanged(position, moves->move, &(moves->buffer));
        
        if (bestmove) {
            value = -_LCPVSSearch(nextStep, -alpha - 1, -alpha, 1);
            
            if (alpha < value) {
                value = -_LCPVSSearch(nextStep, -LCPositionCheckMateValue, -alpha, 1);
            }
        } else {
            value = -_LCPVSSearch(nextStep, -LCPositionCheckMateValue, -alpha, 1);
        }
        
        LCPositionRecover(position, moves->move, &(moves->buffer));
        
        if (value > alpha) {
            alpha = value;
            bestmove = *(moves->move);
        }
        
        progress += 1.0;
        block(progress / countOfMoves, 0);
    }
    
    if (*(nextStep->isThinking)) {
        block(1.0, bestmove);
    }
    
    LCSideRevese(&(position->side));
    
    // 记录Hash、Killer、History
    LCHashHeuristicIOBeginWrite(nextStep->io, position->side, 0, nextStep->rootDepth, LCHashHeuristicTypeExact, alpha, bestmove);
    LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
    
    LCKillerMovesWrite(nextStep->killersLayers, bestmove);
    
    LCHistoryTrackRecord(nextStep->historyTable, bestmove, nextStep->rootDepth);
}
