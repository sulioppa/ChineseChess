//
//  Luna+MoveLegal.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PositionChanged.h"

/* MARK: - 着法合理性检测
 * 生成的着法 检测（吃子检测）
 */
LC_INLINE Bool LCPositionGenerateMoveIsLegal(LCPositionRef position, const LCMove move) {
    return position->board[move >> 8] >> 4 != position->board[move & 0xff] >> 4;
}

/* MARK: - 着法合理性检测
 * 任意着法 合理检测（用于杀手着法）
 */
extern Bool LCPositionAnyMoveIsLegal(LCPositionRef position, const LCMove *const move);
