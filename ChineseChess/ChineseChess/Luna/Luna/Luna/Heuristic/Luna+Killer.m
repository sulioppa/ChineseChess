//
//  Luna+Killer.m
//  Luna
//
//  Created by 李夙璃 on 2018/11/21.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+Killer.h"

#include <stdlib.h>
#include <memory.h>

// MARK: - LCKillerMove Life Cycle
extern LCMutableKillerMovesRef LCKillerMovesCreateMutable(void) {
    const UInt64 size = LCSearchMaxDepth * sizeof(LCKillerMoves);
    
    void *const memory = malloc(size);
    memset(memory, 0, size);
    
    LCKillerMoves *iter = (LCKillerMoves *)memory;
    
    for (int idx = 0; idx < LCSearchMaxDepth; idx++) {
        iter->iter_end = iter->killers + LCKillerMovesLength;
        iter++;
    }
    
    return memory == NULL ? NULL : (LCKillerMoves *)memory;
}

void LCKillerMovesClear(LCMutableKillerMovesRef killer) {
    const UInt64 size = LCSearchMaxDepth * sizeof(LCKillerMoves);
    
    memset(killer, 0, size);
    
    LCKillerMoves *iter = killer;
    
    for (int idx = 0; idx < LCSearchMaxDepth; idx++) {
        iter->iter_end = iter->killers + LCKillerMovesLength;
        iter++;
    }
}

void LCKillerMovesRelease(LCKillerMovesRef killer) {
    if (killer == NULL) {
        return;
    }
    
    free((void *)killer);
}

void LCKillerMovesEnumerateMovesUsingBlock(LCMutableKillerMovesRef killers, void (^ block)(LCMoveRef move, Bool *const stop)) {
    Bool stop = false;
    
    for (killers->iter = killers->killers; killers->iter < killers->iter_end; killers->iter++) {
        if (stop) {
            return;
        }
        
        block(killers->iter, &stop);
    }
}
