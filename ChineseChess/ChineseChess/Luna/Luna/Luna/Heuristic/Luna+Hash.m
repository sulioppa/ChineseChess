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

// MARK: - Write
void LCHashHeuristicWrite(LCMutableHashHeuristicRef hashTable, LCPositionRef position, LCHashHeuristicIORef io) {
#if LC_SingleThread
    static LCHashHeuristic *hash;
#else
    LCHashHeuristic *hash;
#endif
    
    hash = hashTable + position->hash;
    
    if (hash->io.depth > io->depth) {
        hash++;
    }
    
    hash->key = position->key;
    hash->io = *io;
}

// MARK: - Read
LC_INLINE Bool LCPositionCanHitHash(LCPositionRef position, LCHashHeuristicRef hash) {
    return position->key == hash->key && position->side == hash->io.side && hash->io.type;
}

LC_INLINE Bool LCHashHeuristicIOGetValue(LCHashHeuristicIORef io, LCHashHeuristicRef hash, Int16 *const value) {
    if (hash->io.value > LCPositionWinValue) {
        *value = hash->io.value + hash->io.distance - io->distance;
        
        return true;
    } else if (hash->io.value < -LCPositionWinValue) {
        *value = hash->io.value + io->distance - hash->io.distance;
        
        return true;
    } else {
        *value = hash->io.value;
        
        return hash->io.depth >= io->depth;
    }
}

typedef Bool (^ LCHashHeuristicBlock)(LCMutableHashHeuristicIORef io, const Int16);

const LCHashHeuristicBlock _LCHashHeuristicBlocks[LCHashHeuristicTypeMove] = {
    NULL,
    ^ Bool (LCMutableHashHeuristicIORef io, const Int16 value) {
        return value <= io->alpha;
    }, ^ Bool (LCMutableHashHeuristicIORef io, const Int16 value) {
        return true;
    }, ^ Bool (LCMutableHashHeuristicIORef io, const Int16 value) {
        return value >= io->beta;
    }
};

LC_INLINE Bool LCHashHeuristicIOSetValue(LCMutableHashHeuristicIORef io, const LCHashHeuristicType type, const Int16 value) {
    if (_LCHashHeuristicBlocks[type](io, value)) {
        io->value = value;
        io->type = LCHashHeuristicTypeValue;
        
        return true;
    }
    
    return false;
}

LC_INLINE void LCHashHeuristicIOSetHashMove(LCMutableHashHeuristicIORef io, const LCMove move) {
    io->move = move;
    io->type = move ? LCHashHeuristicTypeMove : LCHashHeuristicTypeNan;
}

LC_INLINE void LCHashHeuristicIOSetHashNan(LCMutableHashHeuristicIORef io) {
    io->type = LCHashHeuristicTypeNan;
}

void LCHashHeuristicRead(LCHashHeuristicRef hashTable, LCPositionRef position, LCMutableHashHeuristicIORef io) {
#if LC_SingleThread
    static const LCHashHeuristic *hash;
    static Int16 value;
#else
    const LCHashHeuristic *hash;
    Int16 value;
#endif
    
    hash = hashTable + position->hash;
    
    if (LCPositionCanHitHash(position, hash)) {
        if (LCHashHeuristicIOGetValue(io, hash, &value) && LCHashHeuristicIOSetValue(io, hash->io.type, value)) {
            return;
        } else {
            LCHashHeuristicIOSetHashMove(io, hash->io.move);
        }
    } else {
        hash++;
        
        if (LCPositionCanHitHash(position, hash)) {
            if (LCHashHeuristicIOGetValue(io, hash, &value) && LCHashHeuristicIOSetValue(io, hash->io.type, value)) {
                return;
            } else {
                LCHashHeuristicIOSetHashMove(io, hash->io.move);
            }
        } else {
            LCHashHeuristicIOSetHashNan(io);
        }
    }
}

LCMove LCHashHeuristicReadMove(LCHashHeuristicRef hashTable, LCPositionRef position) {
    const LCHashHeuristic *hash = hashTable + position->hash;
    
    if (LCPositionCanHitHash(position, hash)) {
        return hash->io.move;
    } else {
        hash++;
        
        if (LCPositionCanHitHash(position, hash)) {
            return hash->io.move;
        }
        
        return 0;
    }
}
