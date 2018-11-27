//
//  Luna+Heuristic.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

/* MARK: - LCHistoryTrack
 * the index is move.
 */
typedef struct {
    UInt16 history[LCBoardMapLength];
} LCHistoryTrack;

typedef const LCHistoryTrack *const LCHistoryTrackRef;
typedef LCHistoryTrack *const LCMutableHistoryTrackRef;

// MARK: - LCHistoryTrack Life Cycle
extern LCMutableHistoryTrackRef LCHistoryTrackCreateMutable(void);

extern void LCHistoryTrackClear(LCMutableHistoryTrackRef history);

extern void LCHistoryTrackRelease(LCHistoryTrackRef history);

// MARK: - Write
LC_INLINE void LCHistoryTrackRecord(LCMutableHistoryTrackRef history, const LCMove move, const UInt16 depth) {
    history->history[move] += depth;
}
