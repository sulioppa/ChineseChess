//
//  Luna+PositionDetect.m
//  Luna
//
//  Created by 李夙璃 on 2018/12/14.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+PositionDetect.h"

#include <stdlib.h>
#include <memory.h>

const LCZobristHash LCPositionHashLowMask = 0x7fe; // the lowest bit has being left shift, it = 0.
const LCZobristKey LCPositionHashHighMask = 0x1ff800000000;

LCMutablePositionHashRef LCPositionHashCreateMutable(void) {
    const UInt64 size = sizeof(LCZobristHash) * (1 << 21);
    
    void *memory = malloc(size);
    
    return memory == NULL ? NULL : (LCPositionHash *)memory;
}

void LCPositionHashClear(LCMutablePositionHashRef hash) {
    const UInt64 size = sizeof(LCZobristHash) * (1 << 21);
    
    memset(hash, 0, size);
}

void LCPositionHashRelease(LCPositionHashRef hash) {
    if (hash == NULL) {
        return;
    }
    
    free((void *)hash);
}
