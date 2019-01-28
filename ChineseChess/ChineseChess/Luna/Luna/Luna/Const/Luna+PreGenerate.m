//
//  Luna+PreGenerate.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/8.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna+PreGenerate.h"
#import "Luna+Const.h"

#import <Foundation/Foundation.h>
#include <memory.h>

LCMoveArray _Internal_LCMoveArray;
const LCMoveArray *const LCMoveArrayConstRef = &_Internal_LCMoveArray;

LCMoveMap _Internal_LCMoveMap;
const LCMoveMap *const LCMoveMapConstRef = &_Internal_LCMoveMap;

const LCChess LCZobristMap[LCChessLength] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    
    0,
    1, 1,
    2, 2,
    3, 3,
    4, 4,
    5, 5,
    6, 6, 6, 6, 6,
    
    7,
    8, 8,
    9, 9,
    10, 10,
    11, 11,
    12, 12,
    13, 13, 13, 13, 13
};

LCZobristHash _Internal_LCZobristHash[3584];
const LCZobristHash *const LCZobristConstHash = _Internal_LCZobristHash;

LCZobristKey _Internal_LCZobristKey[3584];
const LCZobristKey *const LCZobristConstKey = _Internal_LCZobristKey;

// MARK: - Init PreGenerate
void _LCInitRank(LCRowColumnOffset *const rankBit, LCRowColumnFlexibility *const rankFlex, LCRowColumnMapState *const rankMap, const LCRowColumnIndex maxIdx, const LCRowColumn maxBound);

void _LCInitRowColumn(void) {
	memset(&_Internal_LCMoveArray, 0, sizeof(_Internal_LCMoveArray));
	_Internal_LCMoveArray.EatR = 0;
	_Internal_LCMoveArray.EatC = 2;
	_Internal_LCMoveArray.EatNone = 4;
	_Internal_LCMoveArray.EatSuperC = 6;
	
	memset(&_Internal_LCMoveMap, 0, sizeof(_Internal_LCMoveMap));
	_Internal_LCMoveMap.Nan = 0;
	_Internal_LCMoveMap.EatNone = 1 << 0;
	_Internal_LCMoveMap.EatR = 1 << 1;
	_Internal_LCMoveMap.EatC = 1 << 2;
	_Internal_LCMoveMap.EatSuperC = 1 << 3;
	_Internal_LCMoveMap.MaskR = _Internal_LCMoveMap.EatNone | _Internal_LCMoveMap.EatR;
	_Internal_LCMoveMap.MaskC = _Internal_LCMoveMap.EatNone | _Internal_LCMoveMap.EatC;
	
	_LCInitRank(_Internal_LCMoveArray.Row, _Internal_LCMoveArray.RowFlexibility, _Internal_LCMoveMap.Row, 11, 0x0fff);
	_LCInitRank(_Internal_LCMoveArray.Column, _Internal_LCMoveArray.ColumnFlexibility, _Internal_LCMoveMap.Column, 12, 0x1fff);
}

void _LCInitZobristValue(void) {
    LCZobristKey buffer;
    const LCZobristHash bound = 1 << (15 + LCHashHeuristicPower);
    
    for (int idx = 0; idx < 3584; idx++) {
        _Internal_LCZobristHash[idx] = arc4random_uniform(bound) << 1;
        
        buffer = arc4random();
        buffer <<= 32;
        
        _Internal_LCZobristKey[idx] = buffer | arc4random();
    }
}

void LCInitPreGenerate(void) {
    _LCInitZobristValue();
    
	// R、C
	_LCInitRowColumn();
	
	// K、A、B、N、P
	const int8_t K_Dir[4] = { -0x10, +0x10, -0x01, +0x01 };
	const int8_t A_Dir[4] = { -0x11, +0x11, -0x0f, +0x0f };
	const int8_t B_Dir[4] = { -0x22, + 0x22, -0x1e, +0x1e };
	const int8_t N_Dir[8] = { -0x21, -0x1f, -0x12, +0x0e, -0x0e, +0x12, +0x1f, +0x21 };
	const int8_t N_Leg[8] = { -0x10, -0x10, -0x01, -0x01, +0x01, +0x01, +0x10, +0x10 };
	const int8_t P_Dir[2][3] = { { -0x01, +0x01, -0x10 }, { -0x01, +0x01, +0x10 } };
	
	int index, count;
	for (int from = 0, to; from < 256; from++) {
		// K
		if (LCLegalLocationConst.K[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + K_Dir[index];
                
				if (LCLegalLocationConst.K[to]) {
					_Internal_LCMoveArray.K[(from << 2) + count] = to;
					_Internal_LCMoveMap.K[LCMoveMake(from, to)] = 1;
                    
					count++;
				}
			}
		}
		
		// A
		if (LCLegalLocationConst.A[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + A_Dir[index];
                
				if (LCLegalLocationConst.A[to]) {
					_Internal_LCMoveArray.A[(from << 2) + count] = to;
					_Internal_LCMoveMap.A[LCMoveMake(from, to)] = 1;
                    
					count++;
				}
			}
		}
		
		// B
		if (LCLegalLocationConst.B[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + B_Dir[index];
                
				if (LCLegalLocationConst.B[to]) {
					_Internal_LCMoveArray.B[(from << 2) + count] = to;
					_Internal_LCMoveMap.B[LCMoveMake(from, to)] = (from + to) >> 1;
                    
					count++;
				}
			}
		}
		
		// N
		if (LCLegalLocationConst.Board[from]) {
			for (index = 0, count = 0; index < 8; index++) {
				to = from + N_Dir[index];
                
				if (LCLegalLocationConst.Board[to]) {
					_Internal_LCMoveArray.N[(from << 3) + count] = to;
					_Internal_LCMoveMap.N[LCMoveMake(from, to)] = from + N_Leg[index];
                    
					count++;
				}
			}
		}
		
		// P
		if (LCLegalLocationConst.P[from]) {
			for (index = 0, count = 0; index < 3; index++) {
				to = from + P_Dir[0][index];
                
				if (LCLegalLocationConst.P[to]) {
					_Internal_LCMoveArray.P[(from << 2) + count] = to;
					_Internal_LCMoveMap.P[LCMoveMake(from, to)] = 1;
                    
					count++;
				}
			}
		}
		
		if (LCLegalLocationConst.P[from + 256]) {
			for (index = 0, count = 0; index < 3; index++) {
				to = from + P_Dir[1][index];
                
				if (LCLegalLocationConst.P[to + 256]) {
					_Internal_LCMoveArray.P[(from << 2) + count + (1 << 10)] = to;
					_Internal_LCMoveMap.P[LCMoveMake(from, to) + (1 << 16)] = 1;
                    
					count++;
				}
			}
		}
	}
}

// MARK: - Init Row & Column
LC_INLINE _Bool _isOne(const uint16_t bit, const uint8_t index) {
	return (bit & (1 << index)) > 0;
}

LC_INLINE int _bitIndex(const uint16_t rank, const uint8_t from, const int offset) {
	return (rank << 7) + (from << 3) + offset;
}

LC_INLINE int _flexIndex(const uint16_t rank, const uint8_t from, const int offset) {
	return (rank << 5) + (from << 1) + offset;
}

LC_INLINE int _mapIndex(const uint16_t rank, const uint8_t from, const uint8_t to) {
	return (rank << 8) + (from << 4) + to;
}

void _LCInitRank(LCRowColumnOffset *const rankBit, LCRowColumnFlexibility *const rankFlex, LCRowColumnMapState *const rankMap, const LCRowColumnIndex maxIdx, const LCRowColumn maxBound) {
	const LCRowColumnIndex minIdx = 3;
	const LCRowColumn minBound = 1 << minIdx;
	
	const LCRowColumnIndex leftRookEatOffset = LCMoveArrayConstRef->EatR;
	const LCRowColumnIndex rightRookEatOffset = leftRookEatOffset + 1;
	
	const LCRowColumnIndex leftCannonEatOffset = LCMoveArrayConstRef->EatC;
	const LCRowColumnIndex rightCannonEatOffset = leftCannonEatOffset + 1;
	
	const LCRowColumnIndex leftNonEatOffset = LCMoveArrayConstRef->EatNone;
	const LCRowColumnIndex rightNonEatOffset = leftNonEatOffset + 1;
	
	const LCRowColumnIndex leftSuperCEatOffset = LCMoveArrayConstRef->EatSuperC;
	const LCRowColumnIndex rightSuperCEatOffset = leftSuperCEatOffset + 1;
	
	const LCRowColumnIndex rookFlexOffset = 0, cannonFlexOffset = 1;
	
	LCRowColumnIndex from, to, idx;
	
	for (LCRowColumn rank = minBound; rank <= maxBound; rank += minBound) {
		for (from = minIdx; from <= maxIdx; from++) {
			if (!_isOne(rank, from)) continue;
			
			// MARK: - search left rook eat move
			for (to = from - 1; to >= minIdx; to--) {
				if (_isOne(rank, to)) break;
			}
			
			if (to >= minIdx) {
				// exist rook eat move
				rankBit[_bitIndex(rank, from, leftRookEatOffset)] = to - from;
				rankFlex[_flexIndex(rank, from, rookFlexOffset)] += 1;
				rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatR;
				
				// store the rook eat in idx
				idx = to;
				
				// search the cannon eat
				for (to--; to >= minIdx; to--) {
					if (_isOne(rank, to)) break;
				}
				
				if (to >= minIdx) {
					// exist cannon eat move
					rankBit[_bitIndex(rank, from, leftCannonEatOffset)] = to - from;
					rankFlex[_flexIndex(rank, from, cannonFlexOffset)] += 1;
					rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatC;
					
					// search the super cannon eat
					for (to--; to >= minIdx; to--) {
						if (_isOne(rank, to)) break;
					}
					
					if (to >= minIdx) {
						// exist super cannon eat move
						rankBit[_bitIndex(rank, from, leftSuperCEatOffset)] = to - from;
						rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatSuperC;
					}
				}
				
				// the stored idx is rook eat, idx + 1 can be max left non eat move
				to = idx + 1;
			} else {
				// the minIdx can be max left non eat move
				to = minIdx;
			}
			
			if (to < from) {
				// exist rook or cannon non eat move
				rankBit[_bitIndex(rank, from, leftNonEatOffset)] = to - from;
				
				rankFlex[_flexIndex(rank, from, rookFlexOffset)] += from - to;
				rankFlex[_flexIndex(rank, from, cannonFlexOffset)] += from - to;
				
				for (idx = to; idx < from; idx++) {
					rankMap[_mapIndex(rank, from, idx)] = LCMoveMapConstRef->EatNone;
				}
			}
			
			// MARK: - search right rook eat move
			for (to = from + 1; to <= maxIdx; to++) {
				if (_isOne(rank, to)) break;
			}
			
			if (to <= maxIdx) {
				// exist rook eat move
				rankBit[_bitIndex(rank, from, rightRookEatOffset)] = to - from;
				rankFlex[_flexIndex(rank, from, rookFlexOffset)] += 1;
				rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatR;
				
				// store the rook eat in idx.
				idx = to;
				
				// search the cannon eat
				for (to++; to <= maxIdx; to++) {
					if (_isOne(rank, to)) break;
				}
				
				if (to <= maxIdx) {
					// exist cannon eat move
					rankBit[_bitIndex(rank, from, rightCannonEatOffset)] = to - from;
					rankFlex[_flexIndex(rank, from, cannonFlexOffset)] += 1;
					rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatC;
					
					// search the super cannon eat
					for (to++; to <= maxIdx; to++) {
						if (_isOne(rank, to)) break;
					}
					
					if (to <= maxIdx) {
						// exist super cannon eat move
						rankBit[_bitIndex(rank, from, rightSuperCEatOffset)] = to - from;
						rankMap[_mapIndex(rank, from, to)] = LCMoveMapConstRef->EatSuperC;
					}
				}
				
				// the stored idx is rook eat, idx - 1 can be max right non eat move
				to = idx - 1;
			} else {
				// the maxIdx can be max right non eat move
				to = maxIdx;
			}
			
			if (to > from) {
				// exist rook or cannon non eat move
				rankBit[_bitIndex(rank, from, rightNonEatOffset)] = to - from;
				
				rankFlex[_flexIndex(rank, from, rookFlexOffset)] += to - from;
				rankFlex[_flexIndex(rank, from, cannonFlexOffset)] += to - from;
				
				for (idx = to; idx > from; idx--) {
					rankMap[_mapIndex(rank, from, idx)] = LCMoveMapConstRef->EatNone;
				}
			}
		}
	}
}
