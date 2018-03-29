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
	const LCLocation Chess[_LCLengthChess];
	const LCLocation Board[_LCLengthBoard];
} LCInitialData;

extern const LCInitialData _LCInitialData;

// MARK: - Luna Legal Location.（合理位置数据）
typedef struct {
	const Bool Board[_LCLengthBoard];
	const Bool K[_LCLengthBoard];
	const Bool A[_LCLengthBoard];
	const Bool B[_LCLengthBoard];
	const Bool P[_LCLengthBoard << 1];
	const LCLocation River;
} LCLegalLocation;

extern const LCLegalLocation _LCLegalLocation;
