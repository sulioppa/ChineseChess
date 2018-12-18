//
//  Luna+PositionChanged.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"
#import "Luna+Generate.h"

extern void LCPositionChanged(LCMutablePositionRef position, const LCMove *const move, UInt16 *const buffer);

extern void LCPositionRecover(LCMutablePositionRef position, const LCMove *const move, UInt16 *const buffer);

extern Bool LCPositionIsLegalIfChangedByTrack(LCMutablePositionRef position, const LCMove *const move, UInt16 *const buffer);
