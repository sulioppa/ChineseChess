//
//  Luna+Evaluate.h
//  Luna
//
//  Created by 李夙璃 on 2018/6/19.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"

typedef struct {
	const Int16 * dynamicChessValue[LCChessLength];
	Int16 value;
} LCEvaluate;

typedef const LCEvaluate *const LCEvaluateRef;

typedef LCEvaluate *const LCMutableEvaluateRef;

// MARK: - LCEvaluate Life Cycle
extern LCMutableEvaluateRef LCEvaluateCreateMutable(void);

extern void LCEvaluateInit(LCPositionRef position, LCMutableEvaluateRef evaluate);

extern void LCEvaluateRelease(LCEvaluateRef evaluate);

// MARK: - Evaluate
extern void LCEvaluatePosition(LCMutableEvaluateRef evaluate, LCPositionRef position);
