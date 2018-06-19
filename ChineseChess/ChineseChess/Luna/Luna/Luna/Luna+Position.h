//
//  Luna+Position.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Typedef.h"

typedef struct {
	LCLocation board[LCBoardLength];
	LCLocation chess[LCChessLength];
	
	LCRowColumn row[LCBoardRowsColumnsLength];
	LCRowColumn column[LCBoardRowsColumnsLength];
	
	LCSide side;
} LCPosition;

typedef const LCPosition *const LCPositionRef;

typedef LCPosition *const LCMutablePositionRef;

// MARK: - LCPosition Life Cycle
extern LCMutablePositionRef LCPositionCreateMutable(void);

@class NSString;
extern void LCPositionInit(LCMutablePositionRef position, NSString *FEN, const LCSide side);

extern void LCPositionRelease(LCPositionRef position);

// MARK: - LCPosition Changed
LC_INLINE void LCRowColumnSetBitValue(LCRowColumn *const rc, const LCRowColumnIndex index, const Bool value) {
	if (value) {
		*rc |= (1 << index);
	} else {
		*rc &= ~(1 << index);
	}
}

LC_INLINE void LCPositionReveseSide(LCMutablePositionRef position) {
	position->side ^= 1;
}
