//
//  Luna+PreGenerate.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/8.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/* MARK: - Luna PreGenerate.（走法预生成）
 * side = 0 is red, 1 is black.
 * 16 ~ 31 is red. like 01xxxx. from 16 to 31: King(16), Advisor, Advisor, Bishop, Bishop, Knight, Knight, Rook, Rook, Cannon, Cannon, Pawn, Pawn, Pawn, Pawn, Pawn(31).
 * 32 ~ 47 is black. like 10xxxx. from 32 to 47, range also like above.
 * the 5th or 6th bit indicates red or black. */
#define Luna_IsNotSameSide(chess, side) (((chess) >> 5) ^ (side))

// MARK: - Luna Move Array.（短程子力 走法数组）
extern uint8_t Luna_MoveArray_K[1 << 10]; // [256][4]
extern uint8_t Luna_MoveArray_A[1 << 10];
extern uint8_t Luna_MoveArray_B[1 << 10];
extern uint8_t Luna_MoveArray_N[1 << 11];  // [256][8]
extern uint8_t Luna_MoveArray_P[1 << 11];  // [2][256][4]

// MARK: - Luna Move Map.（短程子力 走法映射）
extern uint8_t Luna_MoveMap_K[1 << 16]; // [256][256]
extern uint8_t Luna_MoveMap_A[1 << 16];
extern uint8_t Luna_MoveMap_B[1 << 16];
extern uint8_t Luna_MoveMap_N[1 << 16]; // whitch can also be leg map.
extern uint8_t Luna_MoveMap_P[1 << 17]; // [2][256][256]

/* MARK: - Luna RC Row & Column Bit Position （位行位列 走法偏移）
 * the bit indicates the rook or cannon's bit position, such as 0001 0001 1001 0000, assume the rook is at index of 7, it can max left eat is at index of 3, max left non eat is at index of 4, max right eat is at index of 8, max right non eat is not exist.
 * the first dimension row bit and column bit records every position's state,
 * the second dimension indicates the index of rook or cannon,
 * the third dimension records the max {
 		left rook eat, right rook eat, left cannnon eat, right cannnon eat,
 		left non eat, right non eat, left super cannon eat, right super cannon eat }
 */
extern int8_t Luna_RowBit[1 << 19]; // [2 ^ 12][2 ^ 4][2 ^ 3]
extern int16_t Luna_ColumnBit[1 << 20]; // [2 ^ 13][2 ^ 4][2 ^ 3]

/* MARK: - Luna RC Row & Column Flexibility（位行位列 灵活度）
 * the third dimension indicates the flexibility of rook and cannon. { rook flexibility, cannon flexibility } */
extern uint8_t Luna_RowFlexibility[1 << 17]; // [2 ^ 12][2 ^ 4][2 ^ 1]
extern uint8_t Luna_ColumnFlexibility[1 << 18]; // [2 ^ 13][2 ^ 4][2 ^ 1]

/* MARK: - Luna RC Row & Column Map State（位行位列 走法状态）
 * this enum reveals the from -> to 's state, it can be eat or no eat or cannot eat. */
typedef NS_ENUM(uint8_t, LunaRowColumnMapState) {
	LunaRowColumnMapStateMoveNull = 0,
	LunaRowColumnMapStateEatNone = 1 << 0,
	LunaRowColumnMapStateEatR = 1 << 1,
	LunaRowColumnMapStateEatC = 1 << 2,
	LunaRowColumnMapStateEatSuperC = 1 << 3,
};

// this two mask indicates rook or cannon's move, eat or no eat.
extern const uint8_t LunaRowColumnMapStateMaskR;
extern const uint8_t LunaRowColumnMapStateMaskC;

/* MARK: - Luna RC Row & Column Map（位行位列 走法状态映射）
 * the third dimension indicates the target index, so the second dimension and third dimension can indicates the state of the index of rook to the target index.
 * so I can ask, is index to target index is rook eat? cannon eat? super cannon eat? eat nothing? or it cannot move to target index.
 */
extern LunaRowColumnMapState Luna_RowMap[1 << 20]; // [2 ^ 12][2 ^ 4][2 ^ 4]
extern LunaRowColumnMapState Luna_ColumnMap[1 << 21]; // [2 ^ 13][2 ^ 4][2 ^ 4]

// MARK: - Init PreGenerate.（走法预生成 计算）
extern void Luna_Init_PreGenerate(void);
