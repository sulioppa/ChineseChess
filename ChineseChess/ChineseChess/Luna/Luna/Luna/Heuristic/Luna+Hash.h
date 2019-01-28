//
//  Luna+Hash.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"
#import "Luna+Position.h"

typedef UInt8 LCDepth;

typedef enum : UInt8 {
    LCHashHeuristicTypeNan = 0,
    LCHashHeuristicTypeAlpha = 1 << 0,
    LCHashHeuristicTypeExact = 1 << 1,
    LCHashHeuristicTypeBeta = LCHashHeuristicTypeAlpha | LCHashHeuristicTypeExact,
    LCHashHeuristicTypeValue = LCHashHeuristicTypeBeta,
    LCHashHeuristicTypeMove = 1 << 2
} LCHashHeuristicType;

// MARK: - IO = 8 bytes
typedef struct {
    LCSide side;
    LCDepth distance;
    LCDepth depth;
    LCHashHeuristicType type;
    
    union {
        Int16 value;
        Int16 alpha;
    };
    
    union {
        LCMove move;
        Int16 beta;
    };
} LCHashHeuristicIO;

typedef const LCHashHeuristicIO *const LCHashHeuristicIORef;
typedef LCHashHeuristicIO *const LCMutableHashHeuristicIORef;

// MARK: - IO Life Cycle
extern LCMutableHashHeuristicIORef LCHashHeuristicIOCreateMutable(void);

LC_INLINE void LCHashHeuristicIOBeginWrite(
                                           LCMutableHashHeuristicIORef io,
                                           const LCSide side,
                                           const LCDepth distance,
                                           const LCDepth depth,
                                           const LCHashHeuristicType type,
                                           const Int16 value,
                                           const LCMove move
                                           )
{
    io->side = side;
    io->distance = distance;
    io->depth = depth;
    io->type = type;
    io->value = value;
    io->move = move;
}

LC_INLINE void LCHashHeuristicIOBeginRead(
                                          LCMutableHashHeuristicIORef io,
                                          const LCDepth distance,
                                          const LCDepth depth,
                                          const Int16 alpha,
                                          const Int16 beta
                                          )
{
    io->distance = distance;
    io->depth = depth;
    io->alpha = alpha;
    io->beta = beta;
}

extern void LCHashHeuristicIORelease(LCHashHeuristicIORef io);

/* MARK: - LCHashHeuristic = 16 bytes
 * 双层置换表（深度优先、始终替换）
*/
typedef struct {
    LCZobristKey key;
    LCHashHeuristicIO io;
} LCHashHeuristic;

typedef const LCHashHeuristic *const LCHashHeuristicRef;
typedef LCHashHeuristic *const LCMutableHashHeuristicRef;

// MARK: - LCHashHeuristic Life Cycle
extern LCMutableHashHeuristicRef LCHashHeuristicCreateMutable(void);

extern void LCHashHeuristicClear(LCMutableHashHeuristicRef hash);

extern void LCHashHeuristicRelease(LCHashHeuristicRef hash);

// MARK: - LCHashHeuristic Write & Read
extern void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCHashHeuristicIORef io);

extern void LCHashHeuristicRead(LCHashHeuristicRef hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io);

// MARK: - Return Hash Move
extern LCMove LCHashHeuristicReadMove(LCHashHeuristicRef hashTable, LCPositionRef position);
