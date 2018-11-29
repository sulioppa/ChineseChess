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

/* MARK: - Max Search Depth
 * 影响 `着法列表` 的内存大小
 * 影响 `杀手着法` 的内存大小
 * 影响 `置换表` 的内存大小
 */
#define LCSearchMaxDepth 32

#endif /* Luna_Settings_h */
