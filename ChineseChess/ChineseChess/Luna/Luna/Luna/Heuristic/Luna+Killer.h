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
    UInt8 indexOfRead;
    UInt8 indexOfWrite;
} LCKillerMove;

typedef const LCKillerMove *const LCKillerMoveRef;
typedef LCKillerMove *const LCMutableKillerMoveRef;

// MARK: - Write & Read
LC_INLINE void LCKillerMoveWrite(LCMutableKillerMoveRef killer, const LCMove move) {
    killer->killers[(killer->indexOfWrite++) & LCKillerMoveLengthMask] = move;
}

LC_INLINE void LCKillerMoveBeginRead(LCMutableKillerMoveRef killer) {
    killer->indexOfRead = 0;
}

LC_INLINE LCMove LCKillerMoveRead(LCMutableKillerMoveRef killer) {
    return killer->indexOfRead < LCKillerMoveLength ? killer->killers[killer->indexOfRead++] : 0;
}
