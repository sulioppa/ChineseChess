//
//  Luna+Evaluate.m
//  Luna
//
//  Created by 李夙璃 on 2018/6/19.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Evaluate.h"
#include <stdlib.h>
#include <memory.h>

// MARK: - LCEvaluate Life Cycle
LCMutableEvaluateRef LCEvaluateCreateMutable(void) {
	void *memory = malloc(sizeof(LCEvaluate));
	
	return memory == NULL ? NULL : (LCEvaluate *)memory;
}

void LCEvaluateInit(LCPositionRef position, LCMutableEvaluateRef evaluate) {
	if (position == NULL || evaluate == NULL) {
		return;
	}
	
	memset(evaluate, 0, sizeof(LCEvaluate));
}

void LCEvaluateRelease(LCEvaluateRef evaluate) {
	if (evaluate == NULL) {
		return;
	}
	
	free((void *)evaluate);
}

// MARK: - Evaluate
void LCEvaluatePosition(LCMutableEvaluateRef evaluate, LCPositionRef position) {
	
}
