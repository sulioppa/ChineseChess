//
//  Luna+Position.m
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"
#import "LunaFENCoder.h"

#include <stdlib.h>
#include <memory.h>

// MARK: - LCPosition Life Cycle
LCMutablePositionRef LCPositionCreateMutable(void) {
	void *memory = malloc(sizeof(LCPosition));
	
	return memory == NULL ? NULL : (LCPosition *)memory;
}

LCRowColumn LCPositionGetRowFromBoard(LCPositionRef position, LCRow row);
LCRowColumn LCPositionGetColumnFromBoard(LCPositionRef position, LCRow column);

void LCPositionInit(LCMutablePositionRef position, NSString *FEN, const LCSide side) {
	if (position == NULL || FEN == nil) {
		return;
	}
	
	memset(position, 0, sizeof(LCPosition));
	
	id<LunaCoding> coder = [[LunaFENCoder alloc] init];
	[coder decode:FEN board:position->board];
	
	for (int i = 0; i < LCBoardLength; i++) {
		if (position->board[i]) {
			position->chess[position->board[i]] = i;
			LCBitChessModified(&(position->bitchess), position->board[i], true);
		}
	}
	
	// init row & column
	for (LCRowColumnIndex index = 0; index < LCBoardRowsColumnsLength; index++) {
		position->row[index] = LCPositionGetRowFromBoard(position, index);
		position->column[index] = LCPositionGetColumnFromBoard(position, index);
	}
	
	position->side = side;
}

void LCPositionRelease(LCPositionRef position) {
	if (position == NULL) {
		return;
	}
	
	free((void *)position);
}

// MARK: - LCPosition Row & Column Set
LCRowColumn LCLocationArrayGetLCRowColumn(const LCLocation *const array) {
	LCRowColumn bit = 0;
	
	for (LCRowColumnIndex i = 0; i < LCBoardRowsColumnsLength; i++) {
		LCRowColumnModified(&bit, i, array[i]);
	}
	return bit;
}

LCRowColumn LCPositionGetRowFromBoard(LCPositionRef position, LCRow row) {
	return LCLocationArrayGetLCRowColumn(position->board + (row << 4));
}

LCRowColumn LCPositionGetColumnFromBoard(LCPositionRef position, LCRow column) {
	LCLocation array[16];
	
	for (LCRowColumnIndex row = 0; row < LCBoardRowsColumnsLength; row++) {
		array[row] = position->board[(row << 4) + column];
	}
	return LCLocationArrayGetLCRowColumn(array);
}
