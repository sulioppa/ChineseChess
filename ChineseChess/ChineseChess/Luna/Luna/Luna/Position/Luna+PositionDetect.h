//
//  Luna+PositionDetect.h
//  Luna
//
//  Created by 李夙璃 on 2018/12/14.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+Evaluate.h"

// MARK: - Position Draw （和棋检测）
LC_INLINE Bool LCPositionIsDraw(LCPositionRef position) {
    return !(position->bitchess & 0x07ff07ff);
}

// MARK: - Position Death（杀棋检测）
LC_INLINE Bool LCPositionWasMate(const Int16 alpha, const Int16 beta, const Int8 distance) {
    return alpha >= (LCPositionCheckMateValue - distance) || beta <= (distance - LCPositionCheckMateValue);
}

// MARK: - Position Repetition（重复检测）
typedef LCZobristHash LCPositionHash;

typedef const LCPositionHash *const LCPositionHashRef;
typedef LCPositionHash *const LCMutablePositionHashRef;

extern const LCZobristHash LCPositionHashLowMask;
extern const LCZobristKey LCPositionHashHighMask;

// MARK: - LCPositionHash Life Cycle
extern LCMutablePositionHashRef LCPositionHashCreateMutable(void);

extern void LCPositionHashClear(LCMutablePositionHashRef hash);

extern void LCPositionHashRelease(LCPositionHashRef hash);

#define LCPositionGetHashKey(position) (((position->key & LCPositionHashHighMask >> 32) | (position->hash & LCPositionHashLowMask)) + position->side)
#define LCPositionGetHashValue(position) ((LCPositionHash)(position->key))

// MARK: - Write & Read
LC_INLINE void LCPositionHashSetPosition(LCMutablePositionHashRef hash, LCPositionRef position) {
    *(hash + LCPositionGetHashKey(position)) = LCPositionGetHashValue(position);
}

LC_INLINE void LCPositionHashRemovePosition(LCMutablePositionHashRef hash, LCPositionRef position) {
    *(hash + LCPositionGetHashKey(position)) = 0;
}

LC_INLINE Bool LCPositionHashContainsPosition(LCPositionHashRef hash, LCPositionRef position) {
    return *(hash + LCPositionGetHashKey(position)) == LCPositionGetHashValue(position);
}
