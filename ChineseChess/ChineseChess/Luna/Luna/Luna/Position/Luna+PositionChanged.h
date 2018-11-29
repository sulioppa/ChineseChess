//
//  Luna+PositionChanged.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"
#import "Luna+Generate.h"

extern void LCPositionChanged(LCMutablePositionRef position, LCMoveTrack *const track);

extern void LCPositionRecover(LCMutablePositionRef position, LCMoveTrack *const track);

extern Bool LCPositionIsLegalIfChangedByTrack(LCMutablePositionRef position, LCMoveTrack *const track);
