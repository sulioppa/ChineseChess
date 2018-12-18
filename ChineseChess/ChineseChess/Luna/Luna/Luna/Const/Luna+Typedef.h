//
//  Luna+Typedef.h
//  Luna
//
//  Created by 李夙璃 on 2018/3/29.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#ifndef Luna_Typedef_h
#define Luna_Typedef_h

#include <MacTypes.h>
#include "Luna+Settings.h"

typedef _Bool Bool;

typedef signed char Int8;
typedef short Int16;

typedef UInt8 LCChess;
typedef UInt8 LCLocation;

typedef const UInt8 * LCLocationRef;
typedef UInt8 * LCMutableLocationRef;

#define LCChessLength 48
#define LCBoardLength 256

#define LCChessOffsetRedK 16
#define LCChessOffsetRedN 21

#define LCChessOffsetBlackK 32
#define LCChessOffsetBlackN 37

#define LCBoardMapLength 65536
#define LCBoardRowsColumnsLength 16

#define LCSearchMaxDepth 64

#define LC_INLINE static inline

#endif /* Luna_Typedef_h */
