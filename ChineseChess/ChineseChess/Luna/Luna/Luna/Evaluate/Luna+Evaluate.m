//
//  Luna+Evaluate.m
//  Luna
//
//  Created by 李夙璃 on 2018/6/19.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+Evaluate.h"

#include <stdlib.h>
#include <memory.h>

typedef struct {
    const Int16 K[256 << 1];
    const Int16 AB[256 << 1];
    const Int16 N[256 << 2];
    const Int16 R[256 << 2];
    const Int16 C[256 << 2];
    const Int16 P[256 << 2];
} _LCEvaluateConstValue;

extern const _LCEvaluateConstValue LCEvaluateConstValue;

LC_INLINE UInt16 O(UInt8 row) {
    return row << 8;
}

// MARK: - LCEvaluate Life Cycle
LCMutableEvaluateRef LCEvaluateCreateMutable(void) {
	void *memory = malloc(sizeof(LCEvaluate));
	
	return memory == NULL ? NULL : (LCEvaluate *)memory;
}

void LCEvaluateInit(LCMutableEvaluateRef evaluate, LCPositionRef position) {
	if (position == NULL || evaluate == NULL) {
		return;
	}
	
	memset(evaluate, 0, sizeof(LCEvaluate));
    
    // 阈值、权重
    const UInt8 threadhold = 32;
    const UInt8 w[48] = {
        0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0,0,
        0,
        3, 3,
        2, 2,
        4, 4,
        8, 8,
        5, 5,
        1, 1, 1, 1, 1,
        0,
        3, 3,
        2, 2,
        4, 4,
        8, 8,
        5, 5,
        1, 1, 1, 1, 1
    };
    
    // 判断开中、残局。
    UInt8 y = 0;
    for (int chess = 17; chess < 32; chess++) {
        if (position->chess[chess]) {
            y += w[chess];
        }
    }
    
    if (y <= threadhold) {
        evaluate->dynamicChessValue[16] = LCEvaluateConstValue.K + O(1);
        evaluate->dynamicChessValue[17] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[18] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[19] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[20] = LCEvaluateConstValue.AB + O(1);
        
        evaluate->dynamicChessValue[21] = LCEvaluateConstValue.N + O(2);
        evaluate->dynamicChessValue[22] = LCEvaluateConstValue.N + O(2);
        evaluate->dynamicChessValue[23] = LCEvaluateConstValue.R + O(2);
        evaluate->dynamicChessValue[24] = LCEvaluateConstValue.R + O(2);
        evaluate->dynamicChessValue[25] = LCEvaluateConstValue.C + O(2);
        evaluate->dynamicChessValue[26] = LCEvaluateConstValue.C + O(2);
        
        evaluate->dynamicChessValue[27] = LCEvaluateConstValue.P + O(2);
        evaluate->dynamicChessValue[28] = LCEvaluateConstValue.P + O(2);
        evaluate->dynamicChessValue[29] = LCEvaluateConstValue.P + O(2);
        evaluate->dynamicChessValue[30] = LCEvaluateConstValue.P + O(2);
        evaluate->dynamicChessValue[31] = LCEvaluateConstValue.P + O(2);
    } else {
        evaluate->dynamicChessValue[16] = LCEvaluateConstValue.K + O(0);
        evaluate->dynamicChessValue[17] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[18] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[19] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[20] = LCEvaluateConstValue.AB + O(0);
        
        evaluate->dynamicChessValue[21] = LCEvaluateConstValue.N + O(0);
        evaluate->dynamicChessValue[22] = LCEvaluateConstValue.N + O(0);
        evaluate->dynamicChessValue[23] = LCEvaluateConstValue.R + O(0);
        evaluate->dynamicChessValue[24] = LCEvaluateConstValue.R + O(0);
        evaluate->dynamicChessValue[25] = LCEvaluateConstValue.C + O(0);
        evaluate->dynamicChessValue[26] = LCEvaluateConstValue.C + O(0);
        
        evaluate->dynamicChessValue[27] = LCEvaluateConstValue.P + O(0);
        evaluate->dynamicChessValue[28] = LCEvaluateConstValue.P + O(0);
        evaluate->dynamicChessValue[29] = LCEvaluateConstValue.P + O(0);
        evaluate->dynamicChessValue[30] = LCEvaluateConstValue.P + O(0);
        evaluate->dynamicChessValue[31] = LCEvaluateConstValue.P + O(0);
    }
    
    y = 0;
    for (int chess = 33; chess < LCChessLength; chess++) {
        if (position->chess[chess]) {
            y += w[chess];
        }
    }
    
    if (y <= threadhold) {
        evaluate->dynamicChessValue[32] = LCEvaluateConstValue.K + O(1);
        evaluate->dynamicChessValue[33] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[34] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[35] = LCEvaluateConstValue.AB + O(1);
        evaluate->dynamicChessValue[36] = LCEvaluateConstValue.AB + O(1);
        
        evaluate->dynamicChessValue[37] = LCEvaluateConstValue.N + O(3);
        evaluate->dynamicChessValue[38] = LCEvaluateConstValue.N + O(3);
        evaluate->dynamicChessValue[39] = LCEvaluateConstValue.R + O(3);
        evaluate->dynamicChessValue[40] = LCEvaluateConstValue.R + O(3);
        evaluate->dynamicChessValue[41] = LCEvaluateConstValue.C + O(3);
        evaluate->dynamicChessValue[42] = LCEvaluateConstValue.C + O(3);
        
        evaluate->dynamicChessValue[43] = LCEvaluateConstValue.P + O(3);
        evaluate->dynamicChessValue[44] = LCEvaluateConstValue.P + O(3);
        evaluate->dynamicChessValue[45] = LCEvaluateConstValue.P + O(3);
        evaluate->dynamicChessValue[46] = LCEvaluateConstValue.P + O(3);
        evaluate->dynamicChessValue[47] = LCEvaluateConstValue.P + O(3);
    } else {
        evaluate->dynamicChessValue[32] = LCEvaluateConstValue.K + O(0);
        evaluate->dynamicChessValue[33] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[34] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[35] = LCEvaluateConstValue.AB + O(0);
        evaluate->dynamicChessValue[36] = LCEvaluateConstValue.AB + O(0);
        
        evaluate->dynamicChessValue[37] = LCEvaluateConstValue.N + O(1);
        evaluate->dynamicChessValue[38] = LCEvaluateConstValue.N + O(1);
        evaluate->dynamicChessValue[39] = LCEvaluateConstValue.R + O(1);
        evaluate->dynamicChessValue[40] = LCEvaluateConstValue.R + O(1);
        evaluate->dynamicChessValue[41] = LCEvaluateConstValue.C + O(1);
        evaluate->dynamicChessValue[42] = LCEvaluateConstValue.C + O(1);
        
        evaluate->dynamicChessValue[43] = LCEvaluateConstValue.P + O(1);
        evaluate->dynamicChessValue[44] = LCEvaluateConstValue.P + O(1);
        evaluate->dynamicChessValue[45] = LCEvaluateConstValue.P + O(1);
        evaluate->dynamicChessValue[46] = LCEvaluateConstValue.P + O(1);
        evaluate->dynamicChessValue[47] = LCEvaluateConstValue.P + O(1);
    }
    
    // 计算子力位置价值
    evaluate->material = 0;
    
    for (int chess = 16; chess < LCChessLength; chess++) {
        if (position->chess[chess]) {
            evaluate->material += (evaluate->dynamicChessValue[chess])[position->chess[chess]];
        }
    }
}

void LCEvaluateRelease(LCEvaluateRef evaluate) {
	if (evaluate == NULL) {
		return;
	}
	
	free((void *)evaluate);
}

/* MARK: - Dynamic Evaluate Value
 * 动态评估常量
 */
#define _ThreatK 8
#define _ThreatA 5
#define _ThreatB 4
#define _ThreatN 8
#define _ThreatR 18
#define _ThreatC 9
#define _ThreatP 3

#define _ThreatStrong 4
#define _ThreatMiddle 2
#define _ThreatWeak 1

// MARK: - 少仕相的惩罚
const Int16 _LCThreatAB[16] = {
    _ThreatP * 4, _ThreatP * 3, _ThreatP * 3, _ThreatP * 2,
    _ThreatP * 3, _ThreatP * 2, _ThreatP * 2, _ThreatP * 1,
    _ThreatP * 3, _ThreatP * 2, _ThreatP * 2, _ThreatP * 1,
    _ThreatP * 2, _ThreatP * 1, _ThreatP * 1, _ThreatP * 0
};

LC_INLINE LCBitChess _LCBitChessGetAB(const LCBitChess bitchess, const LCSide side) {
    return bitchess >> (side << 4) >> 1 & 0xf;
}

// MARK: - 馬的控制、牵制、保护
const Int16 _LCThreatRedN[LCChessLength] = {
    _ThreatP, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatMiddle, _ThreatMiddle,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatR / 2, _ThreatR / 2, _ThreatC / 2, _ThreatC / 2,
    _ThreatP, _ThreatP, _ThreatP, _ThreatP, _ThreatP
};

const Int16 _LCThreatBlackN[LCChessLength] = {
    _ThreatP, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatR / 2, _ThreatR / 2, _ThreatC / 2, _ThreatC / 2,
    _ThreatP, _ThreatP, _ThreatP, _ThreatP, _ThreatP,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatMiddle, _ThreatMiddle,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak
};

// MARK: - 車的威胁、隔子牵制
const Int16 _LCThreatRedR[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong, _ThreatMiddle, _ThreatMiddle,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle
};

const Int16 _LCThreatBlackR[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,

    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong, _ThreatMiddle, _ThreatMiddle,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak
};

const Int16 _LCHoldRedR[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    0, 0, 0, 0, 0,
    0, 0, 0, 0, _ThreatWeak, _ThreatWeak,
    0, 0, 0, 0, 0,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, 0, 0,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak
};

const Int16 _LCHoldBlackR[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, 0, 0,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    
    0, 0, 0, 0, 0,
    0, 0, 0, 0, _ThreatWeak, _ThreatWeak,
    0, 0, 0, 0, 0
};

// MARK: - 炮的威胁、隔双子牵制、空头炮/沉底炮的距离
const Int16 _LCThreatRedC[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    
    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle
};

const Int16 _LCThreatBlackC[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,

    _ThreatK, _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle,
    
    0, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatMiddle, _ThreatStrong, _ThreatStrong,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak
};

const Int16 _LCHoldRedC[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    
    _ThreatK, _ThreatWeak, _ThreatWeak, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak
};

const Int16 _LCHoldBlackC[LCChessLength] = {
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    
    _ThreatK, _ThreatWeak, _ThreatWeak, _ThreatMiddle, _ThreatMiddle,
    _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong, _ThreatStrong,
    _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak, _ThreatWeak,
    
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0
};

LC_INLINE const LCLocation _LCLocationGetRowLocation(const LCLocation location, const LCRowColumnOffset offset) {
    return location + offset;
}

LC_INLINE const LCLocation _LCLocationGetColumnLocation(const LCLocation location, const LCRowColumnOffset offset) {
    return location + (offset << 4);
}

// MARK: - Multiple Evaluate（综合 局面评估）
Int16 LCEvaluatePosition(LCMutableEvaluateRef evaluate, LCPositionRef position) {
    /* MARK: - 第一部分。
     * 剩余 子力位置 价值。
     */
    evaluate->value = evaluate->material;
    
    /* MARK: - 第二部分。
     * 少 仕相/士象 的惩罚。
     */
    evaluate->value -= _LCThreatAB[_LCBitChessGetAB(position->bitchess, LCSideRed)];
    evaluate->value += _LCThreatAB[_LCBitChessGetAB(position->bitchess, LCSideBlack)];
    
#if LC_SingleThread
    static LCLocationRef to, toBoundary;
    static LCLocationRef chess, chessBoundary;
    
    static LCRowColumnOffsetRef offset;
#else
    LCLocationRef to, toBoundary;
    LCLocationRef chess, chessBoundary;
    
    LCRowColumnOffsetRef offset;
#endif
    
    // 红馬 的强控制、强保护、弱牵制。
    chess = position->chess + LCChessOffsetRedN;
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            for (to = LCMoveArrayConstRef->N + (*chess << 3), toBoundary = to + 8; to < toBoundary && *to; to++) {
                if (LCChessIsBlack(position->board[*to])) {
                    evaluate->value += _LCThreatRedN[position->board[*to]];
                } else if (!position->board[LCMoveMapConstRef->N[LCMoveMake(*chess, *to)]]) {
                    evaluate->value += _LCThreatRedN[position->board[*to]];
                }
            }
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    // 红車 的威胁、隔子牵制、灵活度。
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            // 横向，左右威胁
            offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatR);
            
            if (*offset) {
                evaluate->value += _LCThreatRedR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCThreatRedR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，左右牵制
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，灵活度
            evaluate->value += LCMoveArrayGetRowFlexibility(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), false);
            
            // 纵向，上下威胁
            offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatR);
            
            if (*offset) {
                evaluate->value += _LCThreatRedR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCThreatRedR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，上下牵制
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，灵活度
            evaluate->value += LCMoveArrayGetColumnFlexibility(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), false);
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    // 红炮 的威胁、隔双子牵制、空头炮/沉底炮、灵活度。
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            // 横向，左右威胁
            offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatC);
            
            if (*offset) {
                evaluate->value += _LCThreatRedC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCThreatRedC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，左右牵制
            offset += 3;
            if (*offset) {
                evaluate->value += _LCHoldRedC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，灵活度
            evaluate->value += LCMoveArrayGetRowFlexibility(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), true);
            
            // 纵向，上下威胁
            offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatC);
            
            if (*offset) {
                evaluate->value += _LCThreatRedC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCThreatRedC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，上下牵制
            offset += 3;
            if (*offset) {
                evaluate->value += _LCHoldRedC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value += _LCHoldRedC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，灵活度
            evaluate->value += LCMoveArrayGetColumnFlexibility(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), true);
            
            // 空头炮、沉底炮
            if (LCLocationRowIsEqualToLocation(*chess, position->chess[LCChessOffsetBlackK])) {
                evaluate->value += LCMoveMapGetRowMapState(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCLocationGetColumn(position->chess[LCChessOffsetBlackK])) == LCMoveMapConstRef->EatR ? _ThreatK : 0;
            } else if (LCLocationColumnIsEqualToLocation(*chess, position->chess[LCChessOffsetBlackK])) {
                evaluate->value += LCMoveMapGetColumnMapState(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCLocationGetRow(position->chess[LCChessOffsetBlackK])) == LCMoveMapConstRef->EatR ? _ThreatK : 0;
            }
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    // 黑馬 的强控制、强保护、弱牵制。
    chess = position->chess + LCChessOffsetBlackN;
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            for (to = LCMoveArrayConstRef->N + (*chess << 3), toBoundary = to + 8; to < toBoundary && *to; to++) {
                if (LCChessIsRed(position->board[*to])) {
                    evaluate->value -= _LCThreatBlackN[position->board[*to]];
                } else if (!position->board[LCMoveMapConstRef->N[LCMoveMake(*chess, *to)]]) {
                    evaluate->value -= _LCThreatBlackN[position->board[*to]];
                }
            }
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    // 黑車 的威胁、隔子牵制、灵活度。
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            // 横向，左右威胁
            offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatR);
            
            if (*offset) {
                evaluate->value -= _LCThreatBlackR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCThreatBlackR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，左右牵制
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackR[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，灵活度
            evaluate->value -= LCMoveArrayGetRowFlexibility(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), false);
            
            // 纵向，上下威胁
            offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatR);
            
            if (*offset) {
                evaluate->value -= _LCThreatBlackR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCThreatBlackR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，上下牵制
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackR[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，灵活度
            evaluate->value -= LCMoveArrayGetColumnFlexibility(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), false);
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    // 黑炮 的威胁、隔双子牵制、空头炮/沉底炮、灵活度。
    chessBoundary = chess + 2;
    
    do {
        if (*chess) {
            // 横向，左右威胁
            offset = LCMoveArrayGetRowOffset(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCMoveArrayConstRef->EatC);
            
            if (*offset) {
                evaluate->value -= _LCThreatBlackC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCThreatBlackC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，左右牵制
            offset += 3;
            if (*offset) {
                evaluate->value -= _LCHoldBlackC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackC[position->board[_LCLocationGetRowLocation(*chess, *offset)]];
            }
            
            // 横向，灵活度
            evaluate->value -= LCMoveArrayGetRowFlexibility(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), true);
            
            // 纵向，上下威胁
            offset = LCMoveArrayGetColumnOffset(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCMoveArrayConstRef->EatC);
            
            if (*offset) {
                evaluate->value -= _LCThreatBlackC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCThreatBlackC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，上下牵制
            offset += 3;
            if (*offset) {
                evaluate->value -= _LCHoldBlackC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            offset++;
            if (*offset) {
                evaluate->value -= _LCHoldBlackC[position->board[_LCLocationGetColumnLocation(*chess, *offset)]];
            }
            
            // 纵向，灵活度
            evaluate->value -= LCMoveArrayGetColumnFlexibility(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), true);
            
            // 空头炮、沉底炮
            if (LCLocationRowIsEqualToLocation(*chess, position->chess[LCChessOffsetRedK])) {
                evaluate->value -= LCMoveMapGetRowMapState(position->row[LCLocationGetRow(*chess)], LCLocationGetColumn(*chess), LCLocationGetColumn(position->chess[LCChessOffsetRedK])) == LCMoveMapConstRef->EatR ? _ThreatK : 0;
            } else if (LCLocationColumnIsEqualToLocation(*chess, position->chess[LCChessOffsetRedK])) {
                evaluate->value -= LCMoveMapGetColumnMapState(position->column[LCLocationGetColumn(*chess)], LCLocationGetRow(*chess), LCLocationGetRow(position->chess[LCChessOffsetRedK])) == LCMoveMapConstRef->EatR ? _ThreatK : 0;
            }
        }
        
        chess++;
    } while (chess < chessBoundary);
    
    /* MARK: - 估值取反。
     * 估值是相对于红方来说的，如果当前结点先行方是黑方，需要取反。
     */
    if (position->side) {
        evaluate->value = -evaluate->value;
    }
    
    return evaluate->value;
}

// MARK: - Const（子力、位置）
const _LCEvaluateConstValue LCEvaluateConstValue = {
    .K = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -11, -15, -11, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -2, -2, -2, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -2, -2, -2, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 11, 15, 11, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -3, -3, -3, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, -5, -5, -5, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    
    .AB = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, -20, -20, 0, -20, -20, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, -23, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -18, 0, 0, -20, -23, -20, 0, 0, -18, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, -20, 0, 0, 0, -20, 0, 0, 0, 0, 0, 0,
        0,  0,  0,  0,  0, 20,  0,  0,  0, 20,  0,  0,  0,  0,  0,  0,
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
        0,  0,  0, 18,  0,  0, 20, 23, 20,  0,  0, 18,  0,  0,  0,  0,
        0,  0,  0,  0,  0,  0,  0, 23,  0,  0,  0,  0,  0,  0,  0,  0,
        0,  0,  0,  0,  0, 20, 20,  0, 20, 20,  0,  0,  0,  0,  0,  0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, -30, -30, 0, -30, -30, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, -33, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -28, 0, 0, -30, -33, -30, 0, 0, -28, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, -30, 0, 0, 0, -30, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 30, 0, 0, 0, 30, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 28, 0, 0, 30, 33, 30, 0, 0, 28, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 33, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 30, 30, 0, 30, 30, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    
    .N = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 90, 90, 90, 96, 90, 96, 90, 90, 90, 0, 0, 0, 0,
        0, 0, 0, 90, 96, 103, 97, 94, 97, 103, 96, 90, 0, 0, 0, 0,
        0, 0, 0, 92, 98, 99, 103, 99, 103, 99, 98, 92, 0, 0, 0, 0,
        0, 0, 0, 93, 108, 100, 107, 100, 107, 100, 108, 93, 0, 0, 0, 0,
        0, 0, 0, 90, 100, 99, 103, 104, 103, 99, 100, 90, 0, 0, 0, 0,
        0, 0, 0, 90, 98, 101, 102, 103, 102, 101, 98, 90, 0, 0, 0, 0,
        0, 0, 0, 92, 94, 98, 95, 98, 95, 98, 94, 92, 0, 0, 0, 0,
        0, 0, 0, 93, 92, 94, 95, 92, 95, 94, 92, 93, 0, 0, 0, 0,
        0, 0, 0, 85, 90, 92, 93, 78, 93, 92, 90, 85, 0, 0, 0, 0,
        0, 0, 0, 88, 85, 90, 88, 90, 88, 90, 85, 88, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -88, -85, -90, -88, -90, -88, -90, -85, -88, 0, 0, 0, 0,
        0, 0, 0, -85, -90, -92, -93, -78, -93, -92, -90, -85, 0, 0, 0, 0,
        0, 0, 0, -93, -92, -94, -95, -92, -95, -94, -92, -93, 0, 0, 0, 0,
        0, 0, 0, -92, -94, -98, -95, -98, -95, -98, -94, -92, 0, 0, 0, 0,
        0, 0, 0, -90, -98, -101, -102, -103, -102, -101, -98, -90, 0, 0, 0, 0,
        0, 0, 0, -90, -100, -99, -103, -104, -103, -99, -100, -90, 0, 0, 0, 0,
        0, 0, 0, -93, -108, -100, -107, -100, -107, -100, -108, -93, 0, 0, 0, 0,
        0, 0, 0, -92, -98, -99, -103, -99, -103, -99, -98, -92, 0, 0, 0, 0,
        0, 0, 0, -90, -96, -103, -97, -94, -97, -103, -96, -90, 0, 0, 0, 0,
        0, 0, 0, -90, -90, -90, -96, -90, -96, -90, -90, -90, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        // N
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 92, 94, 96, 96, 96, 96, 96, 94, 92, 0, 0, 0, 0,
        0, 0, 0, 94, 96, 98, 98, 98, 98, 98, 96, 94, 0, 0, 0, 0,
        0, 0, 0, 96, 98, 100, 100, 100, 100, 100, 98, 96, 0, 0, 0, 0,
        0, 0, 0, 96, 98, 100, 100, 100, 100, 100, 98, 96, 0, 0, 0, 0,
        0, 0, 0, 96, 98, 100, 100, 100, 100, 100, 98, 96, 0, 0, 0, 0,
        0, 0, 0, 94, 96, 98, 98, 98, 98, 98, 96, 94, 0, 0, 0, 0,
        0, 0, 0, 94, 96, 98, 98, 98, 98, 98, 96, 94, 0, 0, 0, 0,
        0, 0, 0, 92, 94, 96, 96, 96, 96, 96, 94, 92, 0, 0, 0, 0,
        0, 0, 0, 90, 92, 94, 92, 92, 92, 94, 92, 90, 0, 0, 0, 0,
        0, 0, 0, 88, 90, 92, 90, 90, 90, 92, 90, 88, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -88, -90, -92, -90, -90, -90, -92, -90, -88, 0, 0, 0, 0,
        0, 0, 0, -90, -92, -94, -92, -92, -92, -94, -92, -90, 0, 0, 0, 0,
        0, 0, 0, -92, -94, -96, -96, -96, -96, -96, -94, -92, 0, 0, 0, 0,
        0, 0, 0, -94, -96, -98, -98, -98, -98, -98, -96, -94, 0, 0, 0, 0,
        0, 0, 0, -94, -96, -98, -98, -98, -98, -98, -96, -94, 0, 0, 0, 0,
        0, 0, 0, -96, -98, -100, -100, -100, -100, -100, -98, -96, 0, 0, 0, 0,
        0, 0, 0, -96, -98, -100, -100, -100, -100, -100, -98, -96, 0, 0, 0, 0,
        0, 0, 0, -96, -98, -100, -100, -100, -100, -100, -98, -96, 0, 0, 0, 0,
        0, 0, 0, -94, -96, -98, -98, -98, -98, -98, -96, -94, 0, 0, 0, 0,
        0, 0, 0, -92, -94, -96, -96, -96, -96, -96, -94, -92, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    
    .R = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 206, 208, 207, 213, 214, 213, 207, 208, 206, 0, 0, 0, 0,
        0, 0, 0, 206, 212, 209, 216, 233, 216, 209, 212, 206, 0, 0, 0, 0,
        0, 0, 0, 206, 208, 207, 214, 216, 214, 207, 208, 206, 0, 0, 0, 0,
        0, 0, 0, 206, 213, 213, 216, 216, 216, 213, 213, 206, 0, 0, 0, 0,
        0, 0, 0, 208, 211, 211, 214, 215, 214, 211, 211, 208, 0, 0, 0, 0,
        0, 0, 0, 208, 212, 212, 214, 215, 214, 212, 212, 208, 0, 0, 0, 0,
        0, 0, 0, 204, 209, 204, 212, 214, 212, 204, 209, 204, 0, 0, 0, 0,
        0, 0, 0, 198, 208, 204, 212, 212, 212, 204, 208, 198, 0, 0, 0, 0,
        0, 0, 0, 200, 208, 206, 212, 200, 212, 206, 208, 200, 0, 0, 0, 0,
        0, 0, 0, 194, 206, 204, 212, 200, 212, 204, 206, 194, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -194, -206, -204, -212, -200, -212, -204, -206, -194, 0, 0, 0, 0,
        0, 0, 0, -200, -208, -206, -212, -200, -212, -206, -208, -200, 0, 0, 0, 0,
        0, 0, 0, -198, -208, -204, -212, -212, -212, -204, -208, -198, 0, 0, 0, 0,
        0, 0, 0, -204, -209, -204, -212, -214, -212, -204, -209, -204, 0, 0, 0, 0,
        0, 0, 0, -208, -212, -212, -214, -215, -214, -212, -212, -208, 0, 0, 0, 0,
        0, 0, 0, -208, -211, -211, -214, -215, -214, -211, -211, -208, 0, 0, 0, 0,
        0, 0, 0, -206, -213, -213, -216, -216, -216, -213, -213, -206, 0, 0, 0, 0,
        0, 0, 0, -206, -208, -207, -214, -216, -214, -207, -208, -206, 0, 0, 0, 0,
        0, 0, 0, -206, -212, -209, -216, -233, -216, -209, -212, -206, 0, 0, 0, 0,
        0, 0, 0, -206, -208, -207, -213, -214, -213, -207, -208, -206, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 182, 182, 182, 184, 186, 184, 182, 182, 182, 0, 0, 0, 0,
        0, 0, 0, 184, 184, 184, 186, 190, 186, 184, 184, 184, 0, 0, 0, 0,
        0, 0, 0, 182, 182, 182, 184, 186, 184, 182, 182, 182, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 180, 180, 180, 182, 184, 182, 180, 180, 180, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -180, -180, -180, -182, -184, -182, -180, -180, -180, 0, 0, 0, 0,
        0, 0, 0, -182, -182, -182, -184, -186, -184, -182, -182, -182, 0, 0, 0, 0,
        0, 0, 0, -184, -184, -184, -186, -190, -186, -184, -184, -184, 0, 0, 0, 0,
        0, 0, 0, -182, -182, -182, -184, -186, -184, -182, -182, -182, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    
    .C = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 96, 91, 90, 91, 96, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 98, 98, 96, 92, 89, 92, 96, 98, 98, 0, 0, 0, 0,
        0, 0, 0, 97, 97, 96, 91, 92, 91, 96, 97, 97, 0, 0, 0, 0,
        0, 0, 0, 96, 99, 99, 98, 100, 98, 99, 99, 96, 0, 0, 0, 0,
        0, 0, 0, 96, 96, 96, 96, 100, 96, 96, 96, 96, 0, 0, 0, 0,
        0, 0, 0, 95, 96, 99, 96, 100, 96, 99, 96, 95, 0, 0, 0, 0,
        0, 0, 0, 96, 96, 96, 96, 96, 96, 96, 96, 96, 0, 0, 0, 0,
        0, 0, 0, 97, 96, 100, 99, 101, 99, 100, 96, 97, 0, 0, 0, 0,
        0, 0, 0, 96, 97, 98, 98, 98, 98, 98, 97, 96, 0, 0, 0, 0,
        0, 0, 0, 96, 96, 97, 99, 99, 99, 97, 96, 96, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -96, -96, -97, -99, -99, -99, -97, -96, -96, 0, 0, 0, 0,
        0, 0, 0, -96, -97, -98, -98, -98, -98, -98, -97, -96, 0, 0, 0, 0,
        0, 0, 0, -97, -96, -100, -99, -101, -99, -100, -96, -97, 0, 0, 0, 0,
        0, 0, 0, -96, -96, -96, -96, -96, -96, -96, -96, -96, 0, 0, 0, 0,
        0, 0, 0, -95, -96, -99, -96, -100, -96, -99, -96, -95, 0, 0, 0, 0,
        0, 0, 0, -96, -96, -96, -96, -100, -96, -96, -96, -96, 0, 0, 0, 0,
        0, 0, 0, -96, -99, -99, -98, -100, -98, -99, -99, -96, 0, 0, 0, 0,
        0, 0, 0, -97, -97, -96, -91, -92, -91, -96, -97, -97, 0, 0, 0, 0,
        0, 0, 0, -98, -98, -96, -92, -89, -92, -96, -98, -98, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -96, -91, -90, -91, -96, -100, -100, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 102, 104, 102, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 102, 104, 102, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 102, 104, 102, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 102, 104, 102, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 102, 104, 102, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 104, 106, 104, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 100, 100, 100, 104, 106, 104, 100, 100, 100, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -104, -106, -104, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -104, -106, -104, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -102, -104, -102, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -102, -104, -102, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -102, -104, -102, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -102, -104, -102, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -102, -104, -102, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -100, -100, -100, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -100, -100, -100, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, -100, -100, -100, -100, -100, -100, -100, -100, -100, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    
    .P = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 9, 9, 9, 11, 13, 11, 9, 9, 9, 0, 0, 0, 0,
        0, 0, 0, 19, 24, 34, 42, 44, 42, 34, 24, 19, 0, 0, 0, 0,
        0, 0, 0, 19, 24, 32, 37, 37, 37, 32, 24, 19, 0, 0, 0, 0,
        0, 0, 0, 19, 23, 27, 29, 30, 29, 27, 23, 19, 0, 0, 0, 0,
        0, 0, 0, 14, 18, 20, 27, 29, 27, 20, 18, 14, 0, 0, 0, 0,
        0, 0, 0, 7, 0, 13, 0, 16, 0, 13, 0, 7, 0, 0, 0, 0,
        0, 0, 0, 7, 0, 7, 0, 15, 0, 7, 0, 7, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -7, 0, -7, 0, -15, 0, -7, 0, -7, 0, 0, 0, 0,
        0, 0, 0, -7, 0, -13, 0, -16, 0, -13, 0, -7, 0, 0, 0, 0,
        0, 0, 0, -14, -18, -20, -27, -29, -27, -20, -18, -14, 0, 0, 0, 0,
        0, 0, 0, -19, -23, -27, -29, -30, -29, -27, -23, -19, 0, 0, 0, 0,
        0, 0, 0, -19, -24, -32, -37, -37, -37, -32, -24, -19, 0, 0, 0, 0,
        0, 0, 0, -19, -24, -34, -42, -44, -42, -34, -24, -19, 0, 0, 0, 0,
        0, 0, 0, -9, -9, -9, -11, -13, -11, -9, -9, -9, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 10, 10, 10, 15, 15, 15, 10, 10, 10, 0, 0, 0, 0,
        0, 0, 0, 50, 55, 83, 85, 100, 85, 83, 55, 50, 0, 0, 0, 0,
        0, 0, 0, 65, 70, 81, 84, 84, 84, 81, 70, 65, 0, 0, 0, 0,
        0, 0, 0, 75, 77, 79, 80, 80, 80, 79, 77, 75, 0, 0, 0, 0,
        0, 0, 0, 70, 70, 70, 70, 70, 70, 70, 70, 70, 0, 0, 0, 0,
        0, 0, 0, 45, 0, 40, 0, 45, 0, 40, 0, 45, 0, 0, 0, 0,
        0, 0, 0, 40, 0, 35, 0, 40, 0, 35, 0, 40, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, -40, 0, -35, 0, -40, 0, -35, 0, -40, 0, 0, 0, 0,
        0, 0, 0, -45, 0, -40, 0, -45, 0, -40, 0, -45, 0, 0, 0, 0,
        0, 0, 0, -70, -70, -70, -70, -70, -70, -70, -70, -70, 0, 0, 0, 0,
        0, 0, 0, -75, -77, -79, -80, -80, -80, -79, -77, -75, 0, 0, 0, 0,
        0, 0, 0, -65, -70, -81, -84, -84, -84, -81, -70, -65, 0, 0, 0, 0,
        0, 0, 0, -50, -55, -83, -85, -100, -85, -83, -55, -50, 0, 0, 0, 0,
        0, 0, 0, -10, -10, -10, -15, -15, -15, -10, -10, -10, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
};

// MARK: - 常量数值
const Int16 LCPositionDrawValue = 10;
const Int16 LCPositionCheckMateValue = 10000;
const Int16 LCPositionWinValue = LCPositionCheckMateValue - 1000;
