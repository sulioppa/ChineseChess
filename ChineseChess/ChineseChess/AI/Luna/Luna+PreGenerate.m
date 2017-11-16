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

// MARK: - Luna RC Row & Column, Flexibility, Map
int8_t Luna_RowBit[1 << 19] = { 0 };
int16_t Luna_ColumnBit[1 << 20] = { 0 };

uint8_t Luna_RowFlexibility[1 << 17] = { 0 };
uint8_t Luna_ColumnFlexibility[1 << 18] = { 0 };

const uint8_t LunaRowColumnMapStateMaskR = LunaRowColumnMapStateEatNone | LunaRowColumnMapStateEatR;
const uint8_t LunaRowColumnMapStateMaskC = LunaRowColumnMapStateEatNone | LunaRowColumnMapStateEatC;

LunaRowColumnMapState Luna_RowMap[1 << 20] = { LunaRowColumnMapStateMoveNull };
LunaRowColumnMapState Luna_ColumnMap[1 << 21] = { LunaRowColumnMapStateMoveNull };

// MARK: - Init Row & Column
void Luna_Init_RowColumn(void) {
	
}

// MARK: - Init PreGenerate
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
					Luna_MoveMap_K[(from << 8) + to] = 1;
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
					Luna_MoveMap_A[(from << 8) + to] = 1;
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
					Luna_MoveMap_B[(from << 8) + to] = 1;
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
					Luna_MoveMap_N[(from << 8) + to] = from + N_Leg[index];;
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
					Luna_MoveMap_P[(from << 8) + to] = 1;
					count++;
				}
			}
		}
		
		if (Luna_LegalLocation_P[from + 256]) {
			for (index = 0, count = 0; index < 3; index++) {
				to = from + P_Dir[1][index];
				if (Luna_LegalLocation_P[to + 256]) {
					Luna_MoveArray_P[(from << 2) + count + (1 << 10)] = to;
					Luna_MoveMap_P[(from << 8) + to + (1 << 16)] = 1;
					count++;
				}
			}
		}
	}
	
	// R、C
	Luna_Init_RowColumn();
}
