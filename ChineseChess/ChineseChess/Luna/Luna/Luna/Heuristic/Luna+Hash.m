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

// 最大搜索步数
const UInt8 LCHashHeuristicMaxDepth = 32;

static LCHashHeuristic *_HashTable;

void LCHashHeuristicInit(void) {
    const UInt64 size = LCHashHeuristicMaxDepth * (UINT16_MAX + 1) * sizeof(LCHashHeuristic);
    
    _HashTable = malloc(size);
    memset(_HashTable, 0, size);
}

// MARK: - Write & Read
void LCHashHeuristicWrite(LCHashHeuristicRef hash) {
    
}

void LCHashHeuristicRead(LCMutableHashHeuristicRef hash) {
    
}
