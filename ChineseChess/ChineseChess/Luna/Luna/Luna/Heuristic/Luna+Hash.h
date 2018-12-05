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
    LCHashHeuristicTypeMove = 1 << 3
} LCHashHeuristicType;

typedef Int8 LCDepth;

/* MARK: - LCHashHeuristic ≤16 bytes
 * 双层置换表（深度优先、始终替换）
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

extern void LCHashHeuristicClear(LCMutableHashHeuristicRef hash);

extern void LCHashHeuristicRelease(LCHashHeuristicRef hash);

// MARK: - IO
typedef struct {
    LCDepth depth;
    LCHashHeuristicType type;
    
    Int16 value;
    LCMove move;
} LCHashHeuristicIO;

typedef const LCHashHeuristicIO *const LCHashHeuristicIORef;
typedef LCHashHeuristicIO *const LCMutableHashHeuristicIORef;

// MARK: - IO Life Cycle
extern LCMutableHashHeuristicIORef LCHashHeuristicIOCreateMutable(void);

LC_INLINE void LCHashHeuristicIOReload(LCMutableHashHeuristicIORef io, const LCDepth depth, const LCHashHeuristicType type, const Int16 value, const LCMove move) {
    io->depth = depth;
    io->type = type;
    io->value = value;
    io->move = move;
}

extern void LCHashHeuristicIORelease(LCHashHeuristicIORef io);

// MARK: - Hash Write & Read
extern void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io);

extern void LCHashHeuristicRead(LCHashHeuristic hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io);
