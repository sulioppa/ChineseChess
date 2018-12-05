//
//  Luna+Hash.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Hash.h"
#import "Luna+Evaluate.h"

#include <stdlib.h>
#include <memory.h>

LCMutableHashHeuristicRef LCHashHeuristicCreateMutable(void) {
    const UInt64 size = sizeof(LCHashHeuristic) * (1 << (16 + LCHashHeuristicPower));
    
    void *memory = malloc(size);
    memset(memory, 0, size);
    
    return memory == NULL ? NULL : (LCHashHeuristic *)memory;
}

void LCHashHeuristicClear(LCMutableHashHeuristicRef hash) {
    const UInt64 size = sizeof(LCHashHeuristic) * (1 << (16 + LCHashHeuristicPower));
    
    memset(hash, 0, size);
}

void LCHashHeuristicRelease(LCHashHeuristicRef hash) {
    if (hash == NULL) {
        return;
    }
    
    free((void *)hash);
}

// MARK: - IO Life Cycle
LCMutableHashHeuristicIORef LCHashHeuristicIOCreateMutable(void) {
    void *memory = malloc(sizeof(LCHashHeuristicIO));

    return memory == NULL ? NULL : (LCHashHeuristicIO *)memory;
}

void LCHashHeuristicIORelease(LCHashHeuristicIORef io) {
    if (io == NULL) {
        return;
    }
    
    free((void *)io);
}

const int _LCHashHeuristicIOOffset = sizeof(LCZobristKey) + sizeof(LCSide);

// MARK: - Write & Read
void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io) {
#if LC_SingleThread
    static LCHashHeuristic *hash;
#else
    LCHashHeuristic *hash;
#endif
    
    hash = hashTable + position->hash;
    
    if (hash->depth > io->depth) {
        hash++;
        // 始终覆盖
    } else {
        // 深度优先
    }
    
    // 杀棋调整
    if (io->value > LCPositionMateValue) {
        io->value = LCPositionCheckMateValue;
    } else if (io->value < -LCPositionMateValue) {
        io->value = -LCPositionCheckMateValue;
    }
    
    hash->key = position->key;
    hash->side = position->side;
    
    *((LCHashHeuristicIO *)((void *)hash + _LCHashHeuristicIOOffset)) = *io;
}

void LCHashHeuristicRead(LCHashHeuristic hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io) {
    
}
