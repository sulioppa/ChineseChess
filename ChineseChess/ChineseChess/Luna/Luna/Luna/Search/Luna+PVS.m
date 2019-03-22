//
//  Luna+PVS.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PVS.h"

#import "Luna+PositionChanged.h"
#import "Luna+PositionLegal.h"

#import "Luna+MoveNext.h"
#import "LunaRecordCharacter.h"

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
    rootDepth ++;
    
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
Int16 _LCPVSSearch(LCNextStepRef nextStep, Int16 alpha, const Int16 beta, const UInt8 distance) {
    if (!*(nextStep->isThinking) || LCPositionIsDraw(nextStep->position)) {
        return LCPositionDrawValue;
    }
    
    if (LCPositionHashContainsPosition(nextStep->hash, nextStep->position)) {
        return LCPositionRepetionValue;
    }
    
    if (distance == nextStep->rootDepth) {
        LCHashHeuristicIOBeginRead(nextStep->io, LCHashHeuristicTypeValueOnly, distance);
        LCHashHeuristicRead(nextStep->hashTable, nextStep->position, nextStep->io);
        
        if (nextStep->io->type & LCHashHeuristicTypeValueOnly) {
            return nextStep->io->value;
        }
        
        LCEvaluatePosition(nextStep->evaluate, nextStep->position);
        
        LCHashHeuristicIOBeginWriteValue(nextStep->io, nextStep->position->lock, nextStep->position->side, nextStep->evaluate->value);
        LCHashHeuristicWrite(nextStep->hashTable, nextStep->position, nextStep->io);
        
        return nextStep->evaluate->value;
    }
    
    // Hash
    LCHashHeuristicIOBeginRead(nextStep->io, LCHashHeuristicTypeAll, distance);
    LCHashHeuristicRead(nextStep->hashTable, nextStep->position, nextStep->io);
    
    if (nextStep->io->type & LCHashHeuristicTypeMate) {
        return nextStep->io->value;
    }
    
    LCMutableMovesArrayRef moves = nextStep->movesLayers + distance;
    LCMovesArrayPopAll(moves);
    
    if (nextStep->io->type & LCHashHeuristicTypeMove) {
        LCMovesArrayPushBack(moves, nextStep->io->move);
    } else {
        // Not Hit Hash.
    }
    
    LCMutablePositionRef position = nextStep->position;
    LCPositionHashSetPosition(nextStep->hash, position);
    
    Int16 value;
    Int16 bestvalue = distance - LCPositionCheckMateValue;
    
    const LCMove *move;
    LCMove bestmove = 0;
    
    while ((move = LCNextStepGetNextMove(nextStep, moves, &distance))) {
        if (LCMoveExistDetailGetMoveExist(nextStep->detail, *move, distance)) {
            continue;
        }
        
        LCMoveExistDetailSetMoveExist(nextStep->detail, *move, distance);
        LCPositionChanged(position, nextStep->evaluate, move, &(moves->buffer));
        
        if (LCPositionIsLegal(position)) {
            LCSideRevese(&(position->side));
        } else {
            LCPositionRecover(position, nextStep->evaluate, move, &(moves->buffer));
            continue;
        }
        
        if (bestmove) {
            value = -_LCPVSSearch(nextStep, -alpha - 1, -alpha, distance + 1);
            
            if (alpha < value && value < beta) {
                value = -_LCPVSSearch(nextStep, -beta, -alpha, distance + 1);
            }
        } else {
            value = -_LCPVSSearch(nextStep, -beta, -alpha, distance + 1);
        }
        
        LCSideRevese(&(position->side));
        LCPositionRecover(position, nextStep->evaluate, move, &(moves->buffer));
        
        if (value >= beta || LCPositionWasMate(value, distance)) {
            bestvalue = value;
            bestmove = *move;

            break;
        }
        
        if (value > bestvalue) {
            bestvalue = value;
            bestmove = *move;
            
            if (bestvalue > alpha) {
                alpha = bestvalue;
            }
            
            LCHashHeuristicIOBeginWriteMove(nextStep->io, position->lock, position->side, bestmove);
            LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
        }
    }
    
    LCPositionHashRemovePosition(nextStep->hash, position);
    
    if (bestmove) {
        LCHashHeuristicIOBeginWriteMove(nextStep->io, position->lock, position->side, bestmove);
        LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
        
        LCKillerMovesWrite(nextStep->killersLayers + distance, bestmove);
        LCHistoryTrackRecord(nextStep->historyTable, bestmove, nextStep->rootDepth - distance);
    } else {
        LCHashHeuristicIOBeginWriteValue(nextStep->io, position->lock, position->side, bestvalue);
        LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
    }
    
    for (move = moves->moves; move < moves->bottom; move++) {
        LCMoveExistDetailClearMoveExist(nextStep->detail, *move, distance);
    }
    
    return bestvalue;
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
    
    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMutableMoveRef move, Bool *const stop) {
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
    
    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMutableMoveRef move, Bool *const stop) {
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
    LCHashHeuristicIOBeginRead(nextStep->io, LCHashHeuristicTypeMoveOnly, 0);
    LCHashHeuristicRead(nextStep->hashTable, position, nextStep->io);
    
    if (nextStep->io->type & LCHashHeuristicTypeMove) {
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
    
    LCKillerMovesEnumerateMovesUsingBlock(nextStep->killersLayers, ^(LCMoveRef move, Bool *const stop) {
        if (LCMovesArrayClearMove(moves, move)) {
            LCMovesArrayPushBack(array, *move);
        }
    });

    LCMovesArrayEnumerateMovesUsingBlock(moves, ^(LCMutableMoveRef move, Bool *const stop) {
        if (*move) {
            LCMovesArrayPushBack(array, *move);
        }
    });
    
    *moves = *array;
    
    // Begin PVS Search
    LCEvaluateInit(nextStep->evaluate, position);
    
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
    const Int16 beta = LCPositionCheckMateValue;
    
    for (const LCMove *move = moves->bottom; move < moves->top; move++) {
        if (!*(nextStep->isThinking)) {
            return;
        }
        
        // PVS
        LCPositionChanged(position, nextStep->evaluate, move, &(moves->buffer));
        
        if (bestmove) {
            value = -_LCPVSSearch(nextStep, -alpha - 1, -alpha, 1);
            
            if (alpha < value) {
                value = -_LCPVSSearch(nextStep, -beta, -alpha, 1);
            }
        } else {
            value = -_LCPVSSearch(nextStep, -beta, -alpha, 1);
        }
        
        LCPositionRecover(position, nextStep->evaluate, move, &(moves->buffer));
        
        NSLog(@"%@ = %d", [LunaRecordCharacter characterRecordWithMove:*move board:position->board array:position->chess], value);
        
        if (value > alpha) {
            alpha = value;
            bestmove = *move;
            
            if (LCPositionWasMate(alpha, 1)) {
                break;
            }
        }
        
        progress += 1.0;
        block(progress / countOfMoves, 0);
    }
    
    if (*(nextStep->isThinking)) {
        block(1.0, bestmove);
    }
    
    LCSideRevese(&(position->side));
    
    // 记录Hash、Killer、History
    LCHashHeuristicIOBeginWriteMove(nextStep->io, position->lock, position->side, bestmove);
    LCHashHeuristicWrite(nextStep->hashTable, position, nextStep->io);
    
    LCKillerMovesWrite(nextStep->killersLayers, bestmove);
    LCHistoryTrackRecord(nextStep->historyTable, bestmove, nextStep->rootDepth);
}
