//
//  Luna+Generate.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"

/* MARK: - LCMoveTrack
 * score(high 16)
 * move(low 16)
 */
LC_INLINE LCMoveTrack LCMoveTrackMake(const LCMove move, const LCScore score) {
	return (score << 16) | move;
}

LC_INLINE LCMove LCMoveTrackGetMove(const LCMoveTrack track) {
	return track & 0xffff;
}

LC_INLINE LCScore LCMoveTrackGetScore(const LCMoveTrack track) {
	return track >> 16;
}

// MARK: - LCMovesTrack
typedef struct {
	LCMoveTrack track[LCMoveTrackMaxLength];
	LCMoveTrack *top;
} LCMovesTrack;

typedef const LCMovesTrack *const LCMovesTrackRef;

typedef LCMovesTrack *const LCMutableMovesTrackRef;

LC_INLINE void LCMovesTrackPushBack(LCMutableMovesTrackRef moves, const LCMoveTrack track) {
	*(moves->top++) = track;
}

LC_INLINE void LCMovesTrackPopAll(LCMutableMovesTrackRef moves) {
	moves->top = moves->track;
}

LC_INLINE LCLength LCMovesTrackCapcity(LCMutableMovesTrackRef moves) {
	return moves->top - moves->track;
}

/* MARK: - LCHistoryTrack
 * the index is move.
 */
typedef struct {
	LCScore history[LCBoardMapLength];
} LCHistoryTrack;

typedef const LCHistoryTrack *const LCHistoryTrackRef;

typedef LCHistoryTrack *const LCMutableHistoryTrackRef;

extern void LCHistoryTrackClear(LCMutableHistoryTrackRef history);

LC_INLINE void LCHistoryTrackRecord(LCMutableHistoryTrackRef history, LCMove move, LCScore value) {
	history->history[move] += value;
}

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
extern void LCGenerateSortedEatMoveTracks(LCPositionRef position, LCMutableMovesTrackRef *moves);

/* MARK: - Generate Eat Moves
 * sorted by history
 */
extern void LCGenerateSortedNonEatMoveTracks(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesTrackRef *moves);