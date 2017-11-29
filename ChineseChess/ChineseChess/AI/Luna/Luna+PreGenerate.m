//
//  Luna+PreGenerate.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/8.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna+PreGenerate.h"
#import "Luna+Const.h"

// MARK: - Luna Move Array
uint8_t Luna_MoveArray_K[1 << 10] = { 0 }; // [256][4]
uint8_t Luna_MoveArray_A[1 << 10] = { 0 };
uint8_t Luna_MoveArray_B[1 << 10] = { 0 };
uint8_t Luna_MoveArray_N[1 << 11] = { 0 }; // [256][8]
uint8_t Luna_MoveArray_P[1 << 11] = { 0 }; // [2][256][4]

// MARK: - Luna Move Map
uint8_t Luna_MoveMap_K[1 << 16] = { 0 }; // [256][256]
uint8_t Luna_MoveMap_A[1 << 16] = { 0 };
uint8_t Luna_MoveMap_B[1 << 16] = { 0 };
uint8_t Luna_MoveMap_N[1 << 16] = { 0 };
uint8_t Luna_MoveMap_P[1 << 17] = { 0 }; // [2][256][256]

// MARK: - Luna RC Row & Column
int8_t Luna_RowBit[1 << 19] = { 0 }; // [2 ^ 12][2 ^ 4][2 ^ 3]
int8_t Luna_ColumnBit[1 << 20] = { 0 }; // [2 ^ 13][2 ^ 4][2 ^ 3]

const uint8_t Luna_BitOffset_EatR = 0;
const uint8_t Luna_BitOffset_EatC = 2;
const uint8_t Luna_BitOffset_EatNone = 4;
const uint8_t Luna_BitOffset_SuperEatC = 6;
const int8_t * Luna_Bit(const _Bool isRow, const uint16_t rank, const uint8_t idx, const uint8_t offset) {
	return (isRow ? Luna_RowBit : Luna_ColumnBit) + (rank << 7) + (idx << 3) + offset;
}

// MARK: - Luna RC Flexibility
uint8_t Luna_RowFlexibility[1 << 17] = { 0 }; // [2 ^ 12][2 ^ 4][2 ^ 1]
uint8_t Luna_ColumnFlexibility[1 << 18] = { 0 }; // [2 ^ 13][2 ^ 4][2 ^ 1]

// MARK: - Luna RC Map
const LunaRowColumnMapState LunaRowColumnMapStateMoveNull = 0;
const LunaRowColumnMapState LunaRowColumnMapStateEatNone = 1 << 0;
const LunaRowColumnMapState LunaRowColumnMapStateEatR = 1 << 1;
const LunaRowColumnMapState LunaRowColumnMapStateEatC = 1 << 2;
const LunaRowColumnMapState LunaRowColumnMapStateEatSuperC = 1 << 3;

LunaRowColumnMapState Luna_RowMap[1 << 20] = { LunaRowColumnMapStateMoveNull }; // [2 ^ 12][2 ^ 4][2 ^ 4]
LunaRowColumnMapState Luna_ColumnMap[1 << 21] = { LunaRowColumnMapStateMoveNull }; // [2 ^ 13][2 ^ 4][2 ^ 4]

const LunaRowColumnMapState LunaRowColumnMapStateMaskR = LunaRowColumnMapStateEatNone | LunaRowColumnMapStateEatR;
const LunaRowColumnMapState LunaRowColumnMapStateMaskC = LunaRowColumnMapStateEatNone | LunaRowColumnMapStateEatC;
const LunaRowColumnMapState Luna_Map(const _Bool isRow, const uint16_t rank, const uint8_t from, const uint8_t to) {
	return *((isRow ? Luna_RowMap : Luna_ColumnMap) + (rank << 8) + (from << 4) + to);
}

// MARK: - Init PreGenerate
void Luna_Init_Rank(int8_t *const rankBit, uint8_t *const rankFlex, LunaRowColumnMapState *const rankMap, const uint8_t maxIdx, const uint16_t maxBound);

void Luna_Init_RowColumn(void) {
	Luna_Init_Rank(Luna_RowBit, Luna_RowFlexibility, Luna_RowMap, 11, 0x0fff);
	Luna_Init_Rank(Luna_ColumnBit, Luna_ColumnFlexibility, Luna_ColumnMap, 12, 0x1fff);
}

void Luna_Init_PreGenerate(void) {
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
		if (Luna_LegalLocation_K[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + K_Dir[index];
				if (Luna_LegalLocation_K[to]) {
					Luna_MoveArray_K[(from << 2) + count] = to;
					Luna_MoveMap_K[Luna_MoveMake(from, to)] = 1;
					count++;
				}
			}
		}
		
		// A
		if (Luna_LegalLocation_A[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + A_Dir[index];
				if (Luna_LegalLocation_A[to]) {
					Luna_MoveArray_A[(from << 2) + count] = to;
					Luna_MoveMap_A[Luna_MoveMake(from, to)] = 1;
					count++;
				}
			}
		}
		
		// B
		if (Luna_LegalLocation_B[from]) {
			for (index = 0, count = 0; index < 4; index++) {
				to = from + B_Dir[index];
				if (Luna_LegalLocation_B[to]) {
					Luna_MoveArray_B[(from << 2) + count] = to;
					Luna_MoveMap_B[Luna_MoveMake(from, to)] = 1;
					count++;
				}
			}
		}
		
		// N
		if (Luna_LegalLocation_Board[from]) {
			for (index = 0, count = 0; index < 8; index++) {
				to = from + N_Dir[index];
				if (Luna_LegalLocation_Board[to]) {
					Luna_MoveArray_N[(from << 3) + count] = to;
					Luna_MoveMap_N[Luna_MoveMake(from, to)] = from + N_Leg[index];;
					count++;
				}
			}
		}
		
		// P
		if (Luna_LegalLocation_P[from]) {
			for (index = 0, count = 0; index < 3; index++) {
				to = from + P_Dir[0][index];
				if (Luna_LegalLocation_P[to]) {
					Luna_MoveArray_P[(from << 2) + count] = to;
					Luna_MoveMap_P[Luna_MoveMake(from, to)] = 1;
					count++;
				}
			}
		}
		
		if (Luna_LegalLocation_P[from + 256]) {
			for (index = 0, count = 0; index < 3; index++) {
				to = from + P_Dir[1][index];
				if (Luna_LegalLocation_P[to + 256]) {
					Luna_MoveArray_P[(from << 2) + count + (1 << 10)] = to;
					Luna_MoveMap_P[Luna_MoveMake(from, to) + (1 << 16)] = 1;
					count++;
				}
			}
		}
	}
	
	// R、C
	Luna_Init_RowColumn();
}

// MARK: - Init Row & Column
static inline _Bool _isOne(const uint16_t bit, const uint8_t index) {
	return (bit & (1 << index)) > 0;
}

static inline int _bitIndex(const uint16_t rank, const uint8_t from, const int offset) {
	return (rank << 7) + (from << 3) + offset;
}

static inline int _flexIndex(const uint16_t rank, const uint8_t from, const int offset) {
	return (rank << 5) + (from << 1) + offset;
}

static inline int _mapIndex(const uint16_t rank, const uint8_t from, const uint8_t to) {
	return (rank << 8) + (from << 4) + to;
}

void Luna_Init_Rank(int8_t *const rankBit, uint8_t *const rankFlex, LunaRowColumnMapState *const rankMap, const uint8_t maxIdx, const uint16_t maxBound) {
	const uint8_t minIdx = 3;
	const uint8_t minBound = 1 << minIdx;
	
	const uint8_t leftRookEatOffset = 0, rightRookEatOffset = 1;
	const uint8_t leftCannonEatOffset = 2, rightCannonEatOffset = 3;
	const uint8_t leftNonEatOffset = 4, rightNonEatOffset = 5;
	const uint8_t leftSuperCEatOffset = 6, rightSuperCEatOffset = 7;
	
	const uint8_t rookFlexOffset = 0, cannonFlexOffset = 1;
	
	uint8_t from, to, idx;
	
	for (uint16_t rank = minBound; rank <= maxBound; rank += minBound) {
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
				rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatR;
				
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
					rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatC;
					
					// search the super cannon eat
					for (to--; to >= minIdx; to--) {
						if (_isOne(rank, to)) break;
					}
					
					if (to >= minIdx) {
						// exist super cannon eat move
						rankBit[_bitIndex(rank, from, leftSuperCEatOffset)] = to - from;
						rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatSuperC;
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
					rankMap[_mapIndex(rank, from, idx)] = LunaRowColumnMapStateEatNone;
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
				rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatR;
				
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
					rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatC;
					
					// search the super cannon eat
					for (to++; to <= maxIdx; to++) {
						if (_isOne(rank, to)) break;
					}
					
					if (to <= maxIdx) {
						// exist super cannon eat move
						rankBit[_bitIndex(rank, from, rightSuperCEatOffset)] = to - from;
						rankMap[_mapIndex(rank, from, to)] = LunaRowColumnMapStateEatSuperC;
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
					rankMap[_mapIndex(rank, from, idx)] = LunaRowColumnMapStateEatNone;
				}
			}
		}
	}
}
