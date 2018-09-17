//
//  Luna+Position.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

// MARK: - LCBitChess
typedef UInt32 LCBitChess;

LC_INLINE void LCBitChessModified(LCBitChess *bitchess, const LCChess chess, const Bool isOnBoard) {
	if (isOnBoard) {
		*bitchess |= 1 << (chess - 16);
	} else {
		*bitchess &= ~(1 << (chess - 16));
	}
}

// MARK: - LCPosition
typedef struct {
	LCLocation board[LCBoardLength];
	LCLocation chess[LCChessLength];
	
	LCRowColumn row[LCBoardRowsColumnsLength];
	LCRowColumn column[LCBoardRowsColumnsLength];
	
	LCSide side;
	LCBitChess bitchess;
} LCPosition;

typedef const LCPosition *const LCPositionRef;

typedef LCPosition *const LCMutablePositionRef;

// MARK: - LCPosition Life Cycle
extern LCMutablePositionRef LCPositionCreateMutable(void);

@class NSString;
extern void LCPositionInit(LCMutablePositionRef position, NSString *FEN, const LCSide side);

extern void LCPositionRelease(LCPositionRef position);

// MARK: - LCPosition Property
LC_INLINE Bool LCPositionIsDraw(LCPositionRef position) {
	return !(position->bitchess & 0x07ff07ff);
}
