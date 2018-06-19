//
//  Luna+Evaluate.h
//  Luna
//
//  Created by 李夙璃 on 2018/6/19.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"

typedef struct {
	Int16 value;
	const Int16 * dynamicChessValue[LCChessLength];
	
	union Chess {
		UInt32 chess;
		UInt16 *bit[2];
	} bitchess;
} LCEvaluate;

typedef const LCEvaluate *const LCEvaluateRef;

typedef LCEvaluate *const LCMutableEvaluateRef;

// MARK: - LCEvaluate Life Cycle
extern LCMutableEvaluateRef LCEvaluateCreateMutable(void);

extern void LCEvaluateInit(LCPositionRef position, LCMutableEvaluateRef evaluate);

extern void LCEvaluateRelease(LCEvaluateRef evaluate);

// MARK: - Evaluate
LC_INLINE Bool LCEvaluateIsDraw(LCEvaluateRef evaluate) {
	return !(evaluate->bitchess.chess & 0x07ff07ff);
}

extern void LCEvaluatePosition(LCMutableEvaluateRef evaluate, LCPositionRef position);
