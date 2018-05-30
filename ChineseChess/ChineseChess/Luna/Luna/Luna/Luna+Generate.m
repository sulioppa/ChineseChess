//
//  Luna+Generate.m
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Generate.h"
#include <memory.h>

/* MARK: - LCMvvValue
 * the index is LCChess.
 */
typedef struct {
	LCScore mvv[LCChessLength];
} LCMvvValue;

const LCMvvValue LCMvvValueConst = { {
	0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
	
	64,
	9, 9,
	8, 8,
	10, 10,
	20, 20,
	11, 11,
	5, 5, 5, 5, 5,
	
	64,
	9, 9,
	8, 8,
	10, 10,
	20, 20,
	11, 11,
	5, 5, 5, 5, 5
} };

/* MARK: - LCHistoryTrack
 * the index is move.
 */
void LCHistoryTrackClear(LCMutableHistoryTrackRef history) {
	memset(history->history, 0, LCBoardMapLength);
}

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
void LCGenerateSortedEatMoveTracks(LCPositionRef position, LCMutableMovesTrackRef *moves) {
	
}

/* MARK: - Generate Eat Moves
 * sorted by history
 */
extern void LCGenerateSortedNonEatMoveTracks(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesTrackRef *moves) {
	
}
