//
//  Luna+Hash.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"
#import "Luna+Position.h"

typedef enum : UInt8 {
    LCHashHeuristicTypeNan = 0,
    LCHashHeuristicTypeAlpha = 1 << 0,
    LCHashHeuristicTypeExact = 1 << 1,
    LCHashHeuristicTypeBeta = 1 << 2,
} LCHashHeuristicType;

typedef Int8 LCDepth;

/* MARK: - LCHashHeuristic: 16 bytes
    LCHashHeuristic[LCSearchMaxDepth][UINT16_MAX + 1]
    Needs `LCSearchMaxDepth` MB.
*/
typedef struct {
    LCZobristKey key;

    LCSide side;
    LCDepth depth;
    LCHashHeuristicType type;
    
    Int16 value;
    LCMove move;
} LCHashHeuristic;

typedef const LCHashHeuristic *const LCHashHeuristicRef;
typedef LCHashHeuristic *const LCMutableHashHeuristicRef;

// MARK: - LCHashHeuristic Life Cycle
extern LCMutableHashHeuristicRef LCHashHeuristicCreateMutable(void);

extern void LCHashHeuristicRelease(LCHashHeuristicRef hash);

// MARK: - Write & Read
extern void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCHashHeuristic hash);

extern void LCHashHeuristicRead(LCHashHeuristic hashTable, LCPositionRef position, LCMutableHashHeuristicRef hash);
