//
//  Luna+Hash.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Hash.h"

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

// MARK: - Write & Read
 void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCHashHeuristic hash) {
    
}

void LCHashHeuristicRead(LCHashHeuristic hashTable, LCPositionRef position, LCMutableHashHeuristicRef hash) {
    
}
