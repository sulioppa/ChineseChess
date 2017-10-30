//
//  Luna+Const.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: - Const Data.
extern const uint8_t Luna_InitChess[48];

extern const uint8_t Luna_InitBoard[256];

extern const uint8_t Luna_LegalLocation[256];

#define Luna_IsNotSameSide(chess, side) (((chess) >> 5) ^ (side))
