//
//  Luna+Settings.h
//  Luna
//
//  Created by 李夙璃 on 2018/11/28.
//  Copyright © 2018 StarLab. All rights reserved.
//

#ifndef Luna_Settings_h
#define Luna_Settings_h

/* MARK: - Single Thread Accelerate
 * 单线程加速（局部变量静态化）
 */
#define LC_SingleThread 1

/* MARK: - Size Of HashHeuristic
 * 影响 `置换表` 的大小
 * size = pow(2, LCHashHeuristicPower) MB.
 */
#define LCHashHeuristicPower 5

#endif /* Luna_Settings_h */
