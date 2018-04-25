//
//  Luna+Const.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna+Typedef.h"

// MARK: - Luna Init Data.（棋子数组、棋盘数组初始化数据）
typedef struct {
	const LCLocation Chess[LCChessLength];
	const LCLocation Board[LCBoardLength];
} LCInitialData;

extern const LCInitialData LCInitialDataConst;

// MARK: - Luna Legal Location.（合理位置数据）
typedef struct {
	const Bool Board[LCBoardLength];
	const Bool K[LCBoardLength];
	const Bool A[LCBoardLength];
	const Bool B[LCBoardLength];
	const Bool P[LCBoardLength << 1];
	const LCLocation River;
} LCLegalLocation;

extern const LCLegalLocation LCLegalLocationConst;
