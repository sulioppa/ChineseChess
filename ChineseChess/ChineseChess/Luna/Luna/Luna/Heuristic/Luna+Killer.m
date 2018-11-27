//
//  Luna+Killer.m
//  Luna
//
//  Created by 李夙璃 on 2018/11/21.
//  Copyright © 2018 李夙璃. All rights reserved.
//

#import "Luna+Killer.h"

#include <stdlib.h>
#include <memory.h>

// MARK: - LCKillerMove Life Cycle
extern LCMutableKillerMoveRef LCKillerMoveCreateMutable(void) {
    const UInt64 size = LCSearchMaxDepth * sizeof(LCKillerMove);
    
    void *const memory = malloc(size);
    memset(memory, 0, size);
    
    LCKillerMove *iter = (LCKillerMove *)memory;
    
    for (int idx = 0; idx < LCSearchMaxDepth; idx++) {
        iter->iter_end = iter->killers + LCKillerMoveLength;
        iter++;
    }
    
    return memory == NULL ? NULL : (LCKillerMove *)memory;
}

void LCKillerMoveRelease(LCKillerMoveRef killer) {
    if (killer == NULL) {
        return;
    }
    
    free((void *)killer);
}
