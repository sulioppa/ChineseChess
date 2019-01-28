//
//  Luna+MoveExist.h
//  Luna
//
//  Created by 李夙璃 on 2018/12/16.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import "Luna+PreGenerate.h"

typedef UInt64 LCMoveExistDetail;

typedef const LCMoveExistDetail *const LCMoveExistDetailRef;
typedef LCMoveExistDetail *const LCMutableMoveExistDetailRef;

// MARK: - LCMoveExistDetail Life Cycle
extern LCMutableMoveExistDetailRef LCMoveExistDetailCreateMutable(void);

extern void LCMoveExistDetailClear(LCMutableMoveExistDetailRef detail);

extern void LCMoveExistDetailRelease(LCMoveExistDetailRef detail);

// MARK: - Write & Read
extern const UInt64 LCMoveExistDetailOne;

LC_INLINE void LCMoveExistDetailSetMoveExist(LCMutableMoveExistDetailRef detail, const LCMove move, const UInt8 distance) {
    *(detail + move) |= LCMoveExistDetailOne << distance;
}

LC_INLINE void LCMoveExistDetailClearMoveExist(LCMutableMoveExistDetailRef detail, const LCMove move, const UInt8 distance) {
    *(detail + move) &= ~(LCMoveExistDetailOne << distance);
}

LC_INLINE Bool LCMoveExistDetailGetMoveExist(LCMoveExistDetailRef detail, const LCMove move, const UInt8 distance) {
    return *(detail + move) >> distance & LCMoveExistDetailOne;
}
