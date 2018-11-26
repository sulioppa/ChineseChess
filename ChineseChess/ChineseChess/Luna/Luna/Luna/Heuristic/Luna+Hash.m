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
    const UInt64 size = LCSearchMaxDepth * (UINT16_MAX + 1) * sizeof(LCHashHeuristic);
    
    void *memory = malloc(size);
    memset(memory, 0, size);
    
    return memory == NULL ? NULL : (LCHashHeuristic *)memory;
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
