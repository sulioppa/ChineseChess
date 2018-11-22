//
//  Luna+Hash.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

typedef struct {
    UInt16 hash;
    UInt64 check;
} LCZobristKey;

typedef enum : Int8 {
    LCHashHeuristicAlpha = -1,
    LCHashHeuristicExact = 0,
    LCHashHeuristicBeta = 1,
} LCHashHeuristicType;

/* MARK: - LCHashHeuristic: 16 bytes
    LCHashHeuristic[LCSearchMaxDepth][UINT16_MAX + 1]
    Needs `LCSearchMaxDepth` MB.
*/
typedef struct {
    LCZobristKey zobrist;
    
    LCSide side;
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
extern void LCHashHeuristicWrite(LCHashHeuristicRef hash);

extern void LCHashHeuristicRead(LCMutableHashHeuristicRef hash);
