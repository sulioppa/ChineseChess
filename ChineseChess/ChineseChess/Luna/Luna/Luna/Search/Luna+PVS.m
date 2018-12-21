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
        .killersLayers = LCKillerMoveCreateMutable(),
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
    rootDepth = rootDepth < 0 ? -rootDepth : rootDepth;
    
    nextStep->isThinking = isThinking;
    nextStep->rootDepth = rootDepth > LCSearchMaxDepth ? LCSearchMaxDepth : rootDepth;
}

void LCNextStepDealloc(LCNextStepRef nextStep) {
    LCMoveExistDetailRelease(nextStep->detail);
    LCPositionHashRelease(nextStep->hash);
    
    LCHashHeuristicIORelease(nextStep->io);
    LCMovesArrayRelease(nextStep->movesLayers);
    
    LCHistoryTrackRelease(nextStep->historyTable);
    LCKillerMoveRelease(nextStep->killersLayers);
    LCHashHeuristicRelease(nextStep->hashTable);
    
    LCEvaluateRelease(nextStep->evaluate);
    LCPositionRelease(nextStep->position);
}

// MARK: - Root Search
Int16 LCPVSSearch(LCNextStepRef nextStep, Int16 alpha, Int16 beta, UInt8 distance);

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
    const UInt8 distance = 0;
    countOfMoves = 0;
    
    for (moves->move = moves->bottom; moves->move < moves->top; moves->move++) {
        if (*(moves->move) == 0) {
            continue;
        }
        
        if (LCMoveExistDetailGetMoveExist(nextStep->detail, *(moves->move), distance)) {
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
    
    // 调整次序，hash, killers, eat, non eat.
    LCHashHeuristicIOBeginRead(nextStep->io, distance, nextStep->rootDepth, -LCPositionCheckMateValue, LCPositionCheckMateValue);
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
    LCMovesArray array;
    LCMovesArrayPopAll(&array);
    
    if (LCMovesArrayFilterMove(moves, &onlyMove)) {
        LCMovesArrayPushBack(&array, onlyMove);
    }
    
    LCMutableKillerMoveRef killers = nextStep->killersLayers;
    
    for (killers->iter = killers->killers; killers->iter < killers->iter_end; killers->iter++) {
        if (LCMovesArrayFilterMove(moves, killers->iter)) {
            LCMovesArrayPushBack(&array, *(killers->iter));
        }
    }
    
    for (moves->move = moves->bottom; moves->move < moves->top; moves->move++) {
        if (*(moves->move)) {
            LCMovesArrayPushBack(&array, *(moves->move));
        }
    }
    
    *moves = array;
    
    // Begin PVS Search
    LCEvaluateInit(nextStep->evaluate, position);
    
    LCHashHeuristicClear(nextStep->hashTable);
    LCKillerMoveClear(nextStep->killersLayers);
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
            value = -LCPVSSearch(nextStep, -alpha - 1, -alpha, distance + 1);
            
            if (alpha < value) {
                value = -LCPVSSearch(nextStep, -LCPositionCheckMateValue, -alpha, distance + 1);
            }
        } else {
            value = -LCPVSSearch(nextStep, -LCPositionCheckMateValue, -alpha, distance + 1);
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
    
    // 记录Hash、History、Killer
    LCHashHeuristicIOBeginWrite(nextStep->io, position->side, 0, nextStep->rootDepth, LCHashHeuristicTypeExact, alpha, bestmove);
    LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
    
    LCHistoryTrackRecord(nextStep->historyTable, bestmove, nextStep->rootDepth);
    
    LCKillerMoveWrite(killers, bestmove);
}

Int16 LCPVSSearch(LCNextStepRef nextStep, Int16 alpha, Int16 beta, UInt8 distance) {
    return 0;
}
