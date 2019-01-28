//
//  Luna+MoveLegal.h
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PositionChanged.h"

/* MARK: - 着法合理性检测
 * 任意着法 合理检测（用于杀手着法）
 */
extern Bool LCPositionAnyMoveIsLegal(LCPositionRef position, LCMoveRef move);
