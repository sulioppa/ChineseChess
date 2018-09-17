//
//  Luna+PositionChanged.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Position.h"

LC_INLINE Bool LCPositionMoveIsLegal(LCPositionRef position, const LCMove move) {
    return position->board[move >> 8] >> 4 != position->board[move & 0xff] >> 4;
}
