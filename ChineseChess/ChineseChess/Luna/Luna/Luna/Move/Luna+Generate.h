//
//  Luna+Generate.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"
#import "Luna+Heuristic.h"

/* MARK: - LCMoveTrack
 * move(high 16)
 * buffer(low 16)
 */
typedef UInt32 LCMoveTrack;

LC_INLINE LCMoveTrack LCMoveTrackMake(const LCMove move, const UInt16 score) {
	return (move << 16) | score;
}

LC_INLINE LCMove LCMoveTrackGetMove(const LCMoveTrack *const track) {
	return *((LCMove *)track + 1);
}

LC_INLINE UInt16 LCMoveTrackGetBuffer(const LCMoveTrack *const track) {
    return *((UInt16 *)track);
}

LC_INLINE void LCMoveTrackSetMove(LCMoveTrack *const track, const LCMove move) {
    *((LCMove *)track + 1) = move;
}

LC_INLINE void LCMoveTrackSetBuffer(LCMoveTrack *const track, const UInt16 value) {
    *((UInt16 *)track) = value;
}

#define LCMoveTrackMaxLength 120

// MARK: - LCMovesTrack
typedef struct {
	LCMoveTrack track[LCMoveTrackMaxLength];
    LCMoveTrack *begin;
    LCMoveTrack *end;
} LCMovesTrack;

typedef const LCMovesTrack *const LCMovesTrackRef;

typedef LCMovesTrack *const LCMutableMovesTrackRef;

// MARK: - LCMovesTrack Life Cycle
extern LCMutableMovesTrackRef LCMovesTrackCreateMutable(void);

extern void LCMovesTrackRelease(LCMovesTrackRef track);

LC_INLINE void LCMovesTrackPushBack(LCMutableMovesTrackRef moves, const LCMoveTrack track) {
	*(moves->end++) = track;
}

LC_INLINE void LCMovesTrackPopAll(LCMutableMovesTrackRef moves) {
    moves->begin = moves->track;
	moves->end = moves->begin;
}

LC_INLINE UInt16 LCMovesTrackGetCapcity(LCMutableMovesTrackRef moves) {
	return moves->end - moves->begin;
}

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
extern void LCGenerateSortedEatMoveTracks(LCPositionRef position, LCMutableMovesTrackRef moves);

/* MARK: - Generate Eat Moves
 * sorted by history
 */
extern void LCGenerateSortedNonEatMoveTracks(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesTrackRef moves);
