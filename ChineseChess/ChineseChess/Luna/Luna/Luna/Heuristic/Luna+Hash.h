//
//  Luna+Hash.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"
#import "Luna+Position.h"
#import "Luna+Evaluate.h"

typedef UInt8 LCDepth;
typedef Int16 LCValue;

typedef enum : UInt8 {
    LCHashHeuristicTypeNan = 0,
    LCHashHeuristicTypeMate = 1 << 0,
    LCHashHeuristicTypeExact = 1 << 1,
    LCHashHeuristicTypeMove = 1 << 2,
} LCHashHeuristicType;

typedef enum: UInt8 {
    LCHashHeuristicTypeValueOnly = LCHashHeuristicTypeMate | LCHashHeuristicTypeMove,
    LCHashHeuristicTypeMoveOnly = LCHashHeuristicTypeMove,
    LCHashHeuristicTypeAll = LCHashHeuristicTypeMate | LCHashHeuristicTypeExact | LCHashHeuristicTypeMove
} LCHashHeuristicReadOption;

// MARK: - IO = 8 bytes
typedef struct {
    LCZobristLock lock;
    LCSide side;
    UInt8 type;
    
    union {
        LCValue value;
        LCDepth distance;
    };
    
    LCMove move;
} LCHashHeuristicIO;

typedef const LCHashHeuristicIO *const LCHashHeuristicIORef;
typedef LCHashHeuristicIO *const LCMutableHashHeuristicIORef;

// MARK: - IO Life Cycle
extern LCMutableHashHeuristicIORef LCHashHeuristicIOCreateMutable(void);

extern void LCHashHeuristicIORelease(LCHashHeuristicIORef io);

LC_INLINE void LCHashHeuristicIOBeginWriteMove(
                                           LCMutableHashHeuristicIORef io,
                                           const LCZobristLock lock,
                                           const LCSide side,
                                           const LCMove move
                                           )
{
    io->lock = lock;
    io->side = side;
    io->type = LCHashHeuristicTypeMove;
    io->move = move;
}

LC_INLINE void LCHashHeuristicIOBeginWriteValue(
                                           LCMutableHashHeuristicIORef io,
                                           const LCZobristLock lock,
                                           const LCSide side,
                                           const LCValue value
                                           )
{
    io->lock = lock;
    io->side = side;
    io->type = value < LCPositionDeathValue ? LCHashHeuristicTypeMate : LCHashHeuristicTypeExact;
    io->value = value;
}

LC_INLINE void LCHashHeuristicIOBeginRead(
                                          LCMutableHashHeuristicIORef io,
                                          const LCHashHeuristicReadOption option,
                                          const LCDepth distance
                                          )
{
    io->type = option;
    io->distance = distance;
}

/* MARK: - LCHashHeuristic = 16 bytes
 * 单置换表（始终覆盖）
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
