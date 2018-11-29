//
//  Luna+Position.h
//  Luna
//
//  Created by 李夙璃 on 2018/4/25.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PreGenerate.h"

// MARK: - LCBitChess
typedef UInt32 LCBitChess;

LC_INLINE void LCBitChessAddChess(LCBitChess *bitchess, const LCChess chess) {
    *bitchess |= 1 << (chess - 16);
}

LC_INLINE void LCBitChessRemoveChess(LCBitChess *bitchess, const LCChess chess) {
    *bitchess &= ~(1 << (chess - 16));
}

// MARK: - LCPosition
typedef struct {
    LCLocation board[LCBoardLength];
    LCLocation chess[LCChessLength];
    
    LCRowColumn row[LCBoardRowsColumnsLength];
    LCRowColumn column[LCBoardRowsColumnsLength];
    
    LCSide side;
    LCBitChess bitchess;
    
    LCZobristHash hash;
    LCZobristKey key;
} LCPosition;

typedef const LCPosition *const LCPositionRef;
typedef LCPosition *const LCMutablePositionRef;

// MARK: - LCPosition Life Cycle
extern LCMutablePositionRef LCPositionCreateMutable(void);

@class NSString;
extern void LCPositionInit(LCMutablePositionRef position, NSString *FEN, const LCSide side);

extern void LCPositionRelease(LCPositionRef position);
