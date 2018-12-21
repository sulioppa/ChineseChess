//
//  Luna+Killer.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

#define LCKillerMoveLength 4
#define LCKillerMoveLengthMask 3

/* MARK: - LCKillerMove
 * LCKillerMoveLength = 2 ^ n; (n = 1, 2, 3, ...)
 * LCKillerMoveLengthMask = LCKillerMoveLength - 1;
 */
typedef struct {
    LCMove killers[LCKillerMoveLength];
    const LCMove *iter;
    const LCMove *iter_end;
    UInt8 indexOfWrite;
} LCKillerMove;

typedef const LCKillerMove *const LCKillerMoveRef;
typedef LCKillerMove *const LCMutableKillerMoveRef;

// MARK: - LCKillerMove Life Cycle
extern LCMutableKillerMoveRef LCKillerMoveCreateMutable(void);

extern void LCKillerMoveClear(LCMutableKillerMoveRef killer);

extern void LCKillerMoveRelease(LCKillerMoveRef killer);

// MARK: - Write & Read
LC_INLINE void LCKillerMoveWrite(LCMutableKillerMoveRef killer, const LCMove move) {
    killer->killers[(killer->indexOfWrite++) & LCKillerMoveLengthMask] = move;
}
