//
//  Luna+Generate.m
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Generate.h"
#import "Luna+PreGenerate.h"

#include <stdlib.h>
#include <memory.h>

/* MARK: - LCMvvValue
 * the index is LCChess.
 */
const UInt16 LCMvvValue[16] = {
	64,
	9, 9,
	8, 8,
	10, 10,
	20, 20,
	11, 11,
	5, 5, 5, 5, 5
};

LCMutableMovesTrackRef LCMovesTrackCreateMutable(void) {
    const UInt64 size = LCSearchMaxDepth * sizeof(LCMovesTrack);
    
    void *memory = malloc(size);
    memset(memory, 0, size);
    
    return memory == NULL ? NULL : (LCMovesTrack *)memory;
}

void LCMovesTrackRelease(LCMovesTrackRef track) {
    if (track == NULL) {
        return;
    }
    
    free((void *)track);
}

const unsigned long LCMoveTrackSize = sizeof(LCMoveTrack);

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
void LCGenerateSortedEatMoveTracks(LCPositionRef position, LCMutableMovesTrackRef moves) {
	const LCChess *chess, *chessBoundary;
	const LCLocation *to, *toBoundary;
	const LCRowColumnOffset *offset;
	
	UInt16 buffer;
	
	chess = position->chess + LCSideGetKing(position->side);
	LCMovesTrackPopAll(moves);
	
	// K
	for (to = LCMoveArrayConstRef->K + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
		if (position->board[*to]) {
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, *to), LCMvvValue[position->board[*to]]));
		}
	}
	chess++;
	
	// A
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->A + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
			if (position->board[*to]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, *to), LCMvvValue[position->board[*to]]));
			}
		}
	}
	
	// B
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->B + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
			buffer = LCMoveMake(*chess, *to);
			
			if (position->board[*to] && !position->board[LCMoveMapConstRef->B[buffer]]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(buffer, LCMvvValue[position->board[*to]]));
			}
		}
	}
	
	// N
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->N + *chess, toBoundary = to + 8; to < toBoundary && *to; to++) {
			buffer = LCMoveMake(*chess, *to);
			
			if (position->board[*to] && !position->board[LCMoveMapConstRef->N[buffer]]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(buffer, LCMvvValue[position->board[*to]]));
			}
		}
	}
	
	// R
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		// Row
		offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatR);
		
		if (*offset) {
			buffer = *chess + *offset;
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + *offset;
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatR);
		
		if (*offset) {
			buffer = *chess + (*offset << 4);
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + (*offset << 4);
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
	}
	
	// C
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		// Row
		offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatC);
		
		if (*offset) {
			buffer = *chess + *offset;
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + *offset;
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatC);
		
		if (*offset) {
			buffer = *chess + (*offset << 4);
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + (*offset << 4);
			LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, buffer), LCMvvValue[position->board[buffer]]));
		}
	}
	
	// P
	buffer = position->side << 10;
	for (chessBoundary = chess + 5; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->P + *chess + buffer, toBoundary = to + 3; to < toBoundary && *to; to++) {
			if (position->board[*to]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, *to), LCMvvValue[position->board[*to]]));
			}
		}
	}
	
	// Sort by mvv
	qsort_b(moves->track, LCMovesTrackGetCapcity(moves), LCMoveTrackSize, ^ int (const void *a, const void *b) {
		return *(short *)b - *(short *)a;
	});
}

/* MARK: - Generate Eat Moves
 * sorted by history
 */
void LCGenerateSortedNonEatMoveTracks(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesTrackRef moves) {
	const LCChess *chess, *chessBoundary;
	const LCLocation *to, *toBoundary;
	const LCRowColumnOffset *offset;
	
	UInt16 move;
	
	chess = position->chess + LCSideGetKing(position->side);
	LCMovesTrackPopAll(moves);
	
	// K
	for (to = LCMoveArrayConstRef->K + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
		if (!position->board[*to]) {
			move = LCMoveMake(*chess, *to);
			LCMovesTrackPushBack(moves, LCMoveTrackMake(move, history->history[move]));
		}
	}
	chess++;
	
	// A
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->A + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
			if (!position->board[*to]) {
				move = LCMoveMake(*chess, *to);
				LCMovesTrackPushBack(moves, LCMoveTrackMake(move, history->history[move]));
			}
		}
	}
	
	// B
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->B + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
			move = LCMoveMake(*chess, *to);
			
			if (!position->board[*to] && !position->board[LCMoveMapConstRef->B[move]]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(move, history->history[move]));
			}
		}
	}
	
	// N
	for (chessBoundary = chess + 2; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->N + *chess, toBoundary = to + 8; to < toBoundary && *to; to++) {
			move = LCMoveMake(*chess, *to);
			
			if (!position->board[*to] && !position->board[LCMoveMapConstRef->N[move]]) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(move, history->history[move]));
			}
		}
	}
	
	// R、C
	for (chessBoundary = chess + 4; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		// Row
		offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatNone);
		
		if (*offset) {
			move = *chess + *offset;
			
			while (move < *chess) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, move), history->history[LCMoveMake(*chess, move)]));
				move++;
			}
		}
		
		offset++;
		if (*offset) {
			move = *chess + *offset;
			
			while (move > *chess) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, move), history->history[LCMoveMake(*chess, move)]));
				move--;
			}
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatNone);
		
		if (*offset) {
			move = *chess + (*offset << 4);
			
			while (move < *chess) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, move), history->history[LCMoveMake(*chess, move)]));
				move += 16;
			}
		}
		
		offset++;
		if (*offset) {
			move = *chess + (*offset << 4);
			
			while (move > *chess) {
				LCMovesTrackPushBack(moves, LCMoveTrackMake(LCMoveMake(*chess, move), history->history[LCMoveMake(*chess, move)]));
				move -= 16;
			}
		}
	}
	
	// P
	for (chessBoundary = chess + 5; chess < chessBoundary; chess++) {
		if (!*chess) {
			continue;
		}
		
		for (to = LCMoveArrayConstRef->P + *chess + (position->side << 10), toBoundary = to + 3; to < toBoundary && *to; to++) {
			if (!position->board[*to]) {
				move = LCMoveMake(*chess, *to);
				LCMovesTrackPushBack(moves, LCMoveTrackMake(move, history->history[move]));
			}
		}
	}
	
	// Sort by history
	qsort_b(moves->track, LCMovesTrackGetCapcity(moves), LCMoveTrackSize, ^ int (const void *a, const void *b) {
		return *(short *)b - *(short *)a;
	});
}
