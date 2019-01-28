//
//  Luna+Killer.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

#define LCKillerMovesLength 4
#define LCKillerMovesLengthMask 3

/* MARK: - LCKillerMoves
 * LCKillerMovesLength = 2 ^ n; (n = 1, 2, 3, ...)
 * LCKillerMovesLengthMask = LCKillerMovesLength - 1;
 */
typedef struct {
    LCMove killers[LCKillerMovesLength];
    const LCMove *iter;
    const LCMove *iter_end;
    UInt8 indexOfWrite;
} LCKillerMoves;

typedef const LCKillerMoves *const LCKillerMovesRef;
typedef LCKillerMoves *const LCMutableKillerMovesRef;

// MARK: - LCKillerMove Life Cycle
extern LCMutableKillerMovesRef LCKillerMovesCreateMutable(void);

extern void LCKillerMovesClear(LCMutableKillerMovesRef killer);

extern void LCKillerMovesRelease(LCKillerMovesRef killer);

// MARK: - Write & Read
LC_INLINE void LCKillerMovesWrite(LCMutableKillerMovesRef killer, const LCMove move) {
    killer->killers[(killer->indexOfWrite++) & LCKillerMovesLengthMask] = move;
}

extern void LCKillerMovesEnumerateMovesUsingBlock(LCMutableKillerMovesRef killers, void (^ block)(LCMoveRef move, Bool *const stop));
