//
//  Luna+Generate.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"
#import "Luna+Heuristic.h"

#define LCMovesArrayLength 122

// MARK: - LCMovesArray
typedef struct {
	LCMove moves[LCMovesArrayLength];
    LCMove *bottom;
    LCMove *top;
    UInt16 buffer;
    UInt16 state;
} LCMovesArray;

typedef const LCMovesArray *const LCMovesArrayRef;
typedef LCMovesArray *const LCMutableMovesArrayRef;

// MARK: - LCMovesArray Life Cycle
extern LCMutableMovesArrayRef LCMovesArrayCreateMutable(void);

extern void LCMovesArrayRelease(LCMovesArrayRef moves);

// MARK: - Write & Read
LC_INLINE void LCMovesArrayPushBack(LCMutableMovesArrayRef moves, const LCMove move) {
	*(moves->top++) = move;
}

LC_INLINE void LCMovesArrayPopAll(LCMutableMovesArrayRef moves) {
    moves->bottom = moves->moves;
	moves->top = moves->bottom;
    moves->state = 0;
}

LC_INLINE void LCMovesArrayResetBottom(LCMutableMovesArrayRef moves, const Bool toTop) {
    moves->bottom = toTop ? moves->top : moves->moves;
}

LC_INLINE UInt16 LCMovesArrayGetCapcity(LCMovesArrayRef moves) {
	return moves->top - moves->bottom;
}

extern void LCMovesArrayEnumerateMovesUsingBlock(LCMutableMovesArrayRef moves, void (^ block)(LCMutableMoveRef move, Bool *const stop));

extern Bool LCMovesArrayClearMove(LCMutableMovesArrayRef moves, LCMoveRef target);

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
extern void LCGenerateSortedEatMoves(LCPositionRef position, LCMutableMovesArrayRef moves);

/* MARK: - Generate Non Eat Moves
 * sorted by history
 */
extern void LCGenerateSortedNonEatMoves(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesArrayRef moves);
