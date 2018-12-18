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
const Int16 LCMvvValue[16] = {
	64,
	9, 9,
	8, 8,
	10, 10,
	20, 20,
	11, 11,
	5, 5, 5, 5, 5
};

const unsigned long LCMoveSize = sizeof(LCMove);

LCMutableMovesArrayRef LCMovesArrayCreateMutable(void) {
    const UInt64 size = LCSearchMaxDepth * sizeof(LCMovesArray);
    
    void *memory = malloc(size);
    memset(memory, 0, size);
    
    return memory == NULL ? NULL : (LCMovesArray *)memory;
}

void LCMovesArrayRelease(LCMovesArrayRef moves) {
    if (moves == NULL) {
        return;
    }
    
    free((void *)moves);
}

/* MARK: - Generate Eat Moves
 * sorted by mvv
 */
void LCGenerateSortedEatMoveTracks(LCPositionRef position, LCMutableMovesArrayRef moves) {
#if LC_SingleThread
	static const LCChess *chess, *chessBoundary;
	static const LCLocation *to, *toBoundary;
	static const LCRowColumnOffset *offset;
    
    static UInt16 buffer;
#else
    const LCChess *chess, *chessBoundary;
    const LCLocation *to, *toBoundary;
    const LCRowColumnOffset *offset;
    
    UInt16 buffer;
#endif
	
	chess = position->chess + LCSideGetKing(position->side);

	// K
	for (to = LCMoveArrayConstRef->K + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
		if (position->board[*to]) {
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, *to));
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
				LCMovesArrayPushBack(moves, LCMoveMake(*chess, *to));
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
                LCMovesArrayPushBack(moves, buffer);
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
				LCMovesArrayPushBack(moves, buffer);
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
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + *offset;
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatR);
		
		if (*offset) {
			buffer = *chess + (*offset << 4);
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + (*offset << 4);
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
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
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + *offset;
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatC);
		
		if (*offset) {
			buffer = *chess + (*offset << 4);
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
		}
		
		offset++;
		if (*offset) {
			buffer = *chess + (*offset << 4);
            LCMovesArrayPushBack(moves, LCMoveMake(*chess, buffer));
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
                LCMovesArrayPushBack(moves, LCMoveMake(*chess, *to));
			}
		}
	}
	
	// Sort by mvv
    chess = position->board;
    
    qsort_b(moves->bottom, LCMovesArrayGetCapcity(moves), LCMoveSize, ^ int (const void *a, const void *b) {
        return LCMvvValue[chess[*(LCLocation *)b]] - LCMvvValue[chess[*(LCLocation *)a]];
    });
}

/* MARK: - Generate Eat Moves
 * sorted by history
 */
void LCGenerateSortedNonEatMoveTracks(LCPositionRef position, LCHistoryTrackRef history, LCMutableMovesArrayRef moves) {
#if LC_SingleThread
    static const LCChess *chess, *chessBoundary;
    static const LCLocation *to, *toBoundary;
    static const LCRowColumnOffset *offset;
    
    static UInt16 move;
#else
    const LCChess *chess, *chessBoundary;
    const LCLocation *to, *toBoundary;
    const LCRowColumnOffset *offset;
    
    UInt16 move;
#endif
	
	chess = position->chess + LCSideGetKing(position->side);
	
	// K
	for (to = LCMoveArrayConstRef->K + *chess, toBoundary = to + 4; to < toBoundary && *to; to++) {
		if (!position->board[*to]) {
			move = LCMoveMake(*chess, *to);
            LCMovesArrayPushBack(moves, move);
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
                LCMovesArrayPushBack(moves, move);
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
                LCMovesArrayPushBack(moves, move);
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
                LCMovesArrayPushBack(moves, move);
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
                LCMovesArrayPushBack(moves, LCMoveMake(*chess, move));
				move++;
			}
		}
		
		offset++;
		if (*offset) {
			move = *chess + *offset;
			
			while (move > *chess) {
                LCMovesArrayPushBack(moves, LCMoveMake(*chess, move));
				move--;
			}
		}
		
		// Column
		offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatNone);
		
		if (*offset) {
			move = *chess + (*offset << 4);
			
			while (move < *chess) {
                LCMovesArrayPushBack(moves, LCMoveMake(*chess, move));
				move += 16;
			}
		}
		
		offset++;
		if (*offset) {
			move = *chess + (*offset << 4);
			
			while (move > *chess) {
                LCMovesArrayPushBack(moves, LCMoveMake(*chess, move));
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
                LCMovesArrayPushBack(moves, move);
			}
		}
	}
	
	// Sort by history
    qsort_b(moves->bottom, LCMovesArrayGetCapcity(moves), LCMoveSize, ^ int (const void *a, const void *b) {
        return history[*(LCMove *)b] >= history[*(LCMove *)a] ? 1 : -1;
    });
}
