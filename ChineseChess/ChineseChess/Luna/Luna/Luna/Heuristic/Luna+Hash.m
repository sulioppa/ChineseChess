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

// MARK: - LC_INLINE
LC_INLINE Bool LCPositionCanHitHash(LCPositionRef position, LCHashHeuristicRef hash) {
    return hash->io.type && position->key == hash->key && position->lock == hash->io.lock && position->side == hash->io.side;
}

LC_INLINE void LCHashHeuristicIOSetHashValue(LCMutableHashHeuristicIORef io, LCHashHeuristicRef hash) {
    if (hash->io.type & LCHashHeuristicTypeMate) {
        io->type = LCHashHeuristicTypeMate;
        io->value = io->distance - LCPositionCheckMateValue;
    } else if (hash->io.type & LCHashHeuristicTypeExact) {
        io->type = LCHashHeuristicTypeExact;
        io->value = hash->io.value;
    } else {
        io->type = LCHashHeuristicTypeNan;
    }
}

LC_INLINE void LCHashHeuristicIOSetHashMove(LCMutableHashHeuristicIORef io, const LCMove move) {
    io->move = move;
    io->type = move ? LCHashHeuristicTypeMove : LCHashHeuristicTypeNan;
}

LC_INLINE void LCHashHeuristicIOAppendHashMove(LCMutableHashHeuristicIORef io, const LCMove move) {
    io->move = move;
    io->type |= move ? LCHashHeuristicTypeMove : LCHashHeuristicTypeNan;
}

LC_INLINE void LCHashHeuristicIOSetHashNan(LCMutableHashHeuristicIORef io) {
    io->type = LCHashHeuristicTypeNan;
}

// MARK: - Write
void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCHashHeuristicIORef io) {
#if LC_SingleThread
    static LCHashHeuristic *hash;
#else
    LCHashHeuristic *hash;
#endif
    
    hash = hashTable + position->hash;
    
    if (LCPositionCanHitHash(position, hash)) {
        if (io->type & LCHashHeuristicTypeValueOnly) {
            hash->io.type |= io->type;
            hash->io.value = io->value;
        } else {
            hash->io.type |= LCHashHeuristicTypeMove;
            hash->io.move = io->move;
        }
    } else {
        hash->key = position->key;
        hash->io = *io;
    }
}

// MARK: - Read
void LCHashHeuristicRead(LCHashHeuristicRef hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io) {
#if LC_SingleThread
    static const LCHashHeuristic *hash;
#else
    const LCHashHeuristic *hash;
#endif
    
    hash = hashTable + position->hash;
    
    if (LCPositionCanHitHash(position, hash)) {
        if (io->type == LCHashHeuristicTypeAll) {
            LCHashHeuristicIOSetHashValue(io, hash);
            LCHashHeuristicIOAppendHashMove(io, hash->io.move);
        } else if (io->type == LCHashHeuristicTypeValueOnly) {
            LCHashHeuristicIOSetHashValue(io, hash);
        } else if (io->type == LCHashHeuristicTypeMoveOnly) {
            LCHashHeuristicIOSetHashMove(io, hash->io.move);
        } else {
            LCHashHeuristicIOSetHashNan(io);
        }
    } else {
        LCHashHeuristicIOSetHashNan(io);
    }
}
