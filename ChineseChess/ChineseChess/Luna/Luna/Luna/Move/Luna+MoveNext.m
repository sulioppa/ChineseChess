//
//  Luna+MoveNext.m
//  Luna
//
//  Created by 李夙璃 on 2019/1/24.
//  Copyright © 2019 StarLab. All rights reserved.
//

#import "Luna+MoveNext.h"
#import "Luna+MoveLegal.h"

// MARK: - LCMoveArrayState
typedef enum : UInt16 {
    LCMoveArrayStateHash = 0,
    LCMoveArrayStateEat = 1,
    LCMoveArrayStateKiller = 2,
    LCMoveArrayStateNonEat = 3,
    LCMoveArrayStateOver = 4
} LCMoveArrayState;

// MARK: - Move Output
LCMoveRef LCNextStepGetNextMove(LCNextStepRef nextStep, LCMutableMovesArrayRef moves, const UInt8 *const distance) {
    // Hash
    if (moves->state == LCMoveArrayStateHash) {
        moves->state = LCMoveArrayStateKiller;
        
        if (moves->bottom < moves->top) {
            return moves->bottom++;
        }
    }
    
    // Killer
    if (moves->state == LCMoveArrayStateKiller) {
        LCMutableKillerMovesRef killer = nextStep->killersLayers + *distance;
        
        if (moves->bottom == moves->top) {
            killer->iter = killer->killers;
        }
        
        while (killer->iter < killer->iter_end) {
            if (*(killer->iter) && LCPositionAnyMoveIsLegal(nextStep->position, killer->iter)) {
                LCMovesArrayPushBack(moves, *(killer->iter));
                
                return killer->iter++;
            }
            
            killer->iter++;
        }
        
        moves->bottom = moves->top;
        moves->state = LCMoveArrayStateEat;
    }
    
    // Eat
    if (moves->state == LCMoveArrayStateEat) {
        if (moves->bottom == moves->top) {
            LCGenerateSortedEatMoves(nextStep->position, moves);
        }
        
        if (moves->bottom < moves->top) {
            if (moves->top - moves->bottom == 1) {
                moves->state = LCMoveArrayStateNonEat;
            }
            
            return moves->bottom++;
        }
        
        moves->state = LCMoveArrayStateNonEat;
    }
    
    // Non Eat
    if (moves->state == LCMoveArrayStateNonEat) {
        if (moves->bottom == moves->top) {
            LCGenerateSortedNonEatMoves(nextStep->position, nextStep->historyTable, moves);
        }
        
        if (moves->bottom < moves->top) {
            if (moves->top - moves->bottom == 1) {
                moves->state = LCMoveArrayStateOver;
            }
            
            return moves->bottom++;
        }
        
        moves->state = LCMoveArrayStateOver;
    }
    
    return NULL;
}
