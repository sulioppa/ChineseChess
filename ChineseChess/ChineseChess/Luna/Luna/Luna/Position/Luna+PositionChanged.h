//
//  Luna+PositionChanged.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Evaluate.h"
#import "Luna+Generate.h"

extern void LCPositionChanged(LCMutablePositionRef position, LCMutableEvaluateRef evaluate, LCMoveRef move, UInt16 *const buffer);

extern void LCPositionRecover(LCMutablePositionRef position, LCMutableEvaluateRef evaluate, LCMoveRef move, UInt16 *const buffer);

extern Bool LCPositionIsLegalIfChangedByMove(LCMutablePositionRef position, LCMoveRef move, UInt16 *const buffer);
