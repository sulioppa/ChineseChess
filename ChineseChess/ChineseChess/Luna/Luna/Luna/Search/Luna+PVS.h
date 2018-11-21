//
//  Luna+PVS.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Luna+PreGenerate.h"

extern void LunaGetNextStep(NSString *FEN, LCSide side, NSArray<NSNumber *> *bannedMoves, void (^ block)(float progress, LCMove move));
