//
//  Luna+PVS.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PVS.h"
#import "Luna+Generate.h"
#import "Luna+PositionChanged.h"

// MARK: - Root Search
void LunaGetNextStep(
                     NSString *FEN,
                     LCSide side,
                     NSArray<NSNumber *> *bannedMoves,
                     Bool *isThinking,
                     void (^ block)(float progress, LCMove move)
                     ) {
    LCMutablePositionRef position = LCPositionCreateMutable();
    LCPositionInit(position, FEN, side);
    
    LCPositionRelease(position);
}

// MARK: - PVS
void LCPrincipalVariationSearch() {
    
}
