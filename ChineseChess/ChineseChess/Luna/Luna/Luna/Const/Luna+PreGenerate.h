//
//  Luna+PreGenerate.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/8.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna+Typedef.h"

/* MARK: - Luna Side.
 * side = 0 is red, 1 is black.
 * 16 ~ 31 is red. like 01xxxx. from 16 to 31: King(16), Advisor, Advisor, Bishop, Bishop, Knight, Knight, Rook, Rook, Cannon, Cannon, Pawn, Pawn, Pawn, Pawn, Pawn(31).
 * 32 ~ 47 is black. like 10xxxx. from 32 to 47, range also like above.
 * 5th or 6th bit indicates red or black. */
typedef Bool LCSide;

#define LCSideNan 0xff
#define LCSideRed 0
#define LCSideBlack 1

LC_INLINE void LCSideRevese(LCSide *const side) {
	*side ^= 1;
}

LC_INLINE LCChess LCSideGetKing(const LCSide side) {
	return (side + 1) << 4;
}

LC_INLINE LCSide LCChessGetSide(const LCChess chess) {
	return chess >> 5;
}

LC_INLINE Bool LCChessIsRed(const LCChess chess) {
    return (chess >> 4) & 0x01;
}

LC_INLINE Bool LCChessIsBlack(const LCChess chess) {
    return (chess >> 4) & 0x02;
}

LC_INLINE Bool LCChessSideIsNotSide(const LCChess chess, const LCSide side) {
	return (chess >> 5) ^ side;
}

LC_INLINE Bool LCChessSideIsNotEqualToChess(const LCChess chess, const LCChess chess1) {
	return (chess >> 5) ^ (chess1 >> 5);
}

// MARK: - Luna Row & Column.
typedef UInt8 LCRow;
typedef UInt8 LCColumn;

LC_INLINE LCRow LCLocationGetRow(const LCLocation location) {
	return location >> 4;
}

LC_INLINE LCColumn LCLocationGetColumn(const LCLocation location) {
	return location & 15;
}

LC_INLINE Bool LCLocationRowIsEqualToLocation(const LCLocation location, const LCLocation location1) {
	return (location >> 4) == (location1 >> 4);
}

LC_INLINE Bool LCLocationColumnIsEqualToLocation(const LCLocation location, const LCLocation location1) {
	return (location & 0xf) == (location1 & 0xf);
}

// MARK: - Luna Move.
typedef UInt16 LCMove;

typedef const LCMove *const LCMoveRef;
typedef LCMove *const LCMutableMoveRef;

LC_INLINE LCMove LCMoveMake(const LCLocation from, const LCLocation to) {
	return (from << 8) | to;
}

LC_INLINE LCLocation LCMoveGetLocationFrom(const LCMove move) {
	return move >> 8;
}

LC_INLINE LCLocation LCMoveGetLocationTo(const LCMove move) {
	return move & 0xff;
}

// MARK: - LCRowColumn
typedef UInt16 LCRowColumn;
typedef UInt8 LCRowColumnIndex;

typedef SInt8 LCRowColumnOffset;
typedef const LCRowColumnOffset * LCRowColumnOffsetRef;

typedef UInt8 LCRowColumnFlexibility;
typedef UInt8 LCRowColumnMapState;

LC_INLINE void LCRowColumnModified(LCRowColumn *const rc, const LCRowColumnIndex index, const Bool value) {
	if (value) {
		*rc |= (1 << index);
	} else {
		*rc &= ~(1 << index);
	}
}

LC_INLINE void LCRowColumnAdd(LCRowColumn *const rc, const LCRowColumnIndex index) {
    *rc |= (1 << index);
}

LC_INLINE void LCRowColumnRemove(LCRowColumn *const rc, const LCRowColumnIndex index) {
    *rc &= ~(1 << index);
}

/* MARK: - Luna Move Array.（走法数组）
 *
 * Luna Row & Column Bit Position （位行位列 走法偏移）
 * the bit indicates the rook or cannon's bit position, such as 0001 0001 1001 0000, assume the rook is at index of 7, it can max left eat is at index of 3, max left non eat is at index of 4, max right eat is at index of 8, max right non eat is not exist.
 * the first dimension row bit and column bit records every position's state,
 * the second dimension indicates the index of rook or cannon,
 * the third dimension records the max {
    left rook eat, right rook eat, left cannnon eat, right cannnon eat,
    left non eat, right non eat, left super cannon eat, right super cannon eat }
 *
 * Luna Row & Column Flexibility（位行位列 灵活度）
 * the third dimension indicates the flexibility of rook and cannon. { rook flexibility, cannon flexibility } */
typedef struct {
	LCLocation K[LCBoardLength << 2]; // [256][4]
	LCLocation A[LCBoardLength << 2];
	LCLocation B[LCBoardLength << 2];
	LCLocation N[LCBoardLength << 3]; // [256][8]
	LCLocation P[LCBoardLength << 3]; // [2][256][4]
	
	LCRowColumnOffset Row[1 << 19]; // [2 ^ 12][2 ^ 4][2 ^ 3]
	LCRowColumnOffset Column[1 << 20]; // [2 ^ 13][2 ^ 4][2 ^ 3]
	
	LCRowColumnIndex EatR;
	LCRowColumnIndex EatC;
	LCRowColumnIndex EatNone;
	LCRowColumnIndex EatSuperC;
	
	LCRowColumnFlexibility RowFlexibility[1 << 17]; // [2 ^ 12][2 ^ 4][2 ^ 1]
	LCRowColumnFlexibility ColumnFlexibility[1 << 18]; // [2 ^ 13][2 ^ 4][2 ^ 1]
} LCMoveArray;

extern const LCMoveArray *const LCMoveArrayConstRef;

LC_INLINE LCRowColumnOffsetRef LCMoveArrayGetRowOffset(const LCRowColumn rank, const LCRowColumnIndex idx, const LCRowColumnIndex offset) {
	return LCMoveArrayConstRef->Row + (rank << 7) + (idx << 3) + offset;
}

LC_INLINE LCRowColumnOffsetRef LCMoveArrayGetColumnOffset(const LCRowColumn rank, const LCRowColumnIndex idx, const LCRowColumnIndex offset) {
	return LCMoveArrayConstRef->Column + (rank << 7) + (idx << 3) + offset;
}

LC_INLINE LCRowColumnFlexibility LCMoveArrayGetRowFlexibility(const LCRowColumn rank, const LCRowColumnIndex idx, const Bool isCannon) {
	return *(LCMoveArrayConstRef->RowFlexibility + (rank << 5) + (idx << 1) + isCannon);
}

LC_INLINE LCRowColumnFlexibility LCMoveArrayGetColumnFlexibility(const LCRowColumn rank, const LCRowColumnIndex idx, const Bool isCannon) {
	return *(LCMoveArrayConstRef->ColumnFlexibility + (rank << 5) + (idx << 1) + isCannon);
}

/* MARK: - Luna Move Map.（走法映射）
 *
 * Luna Row & Column Map State（位行位列 走法状态）
 * this values reveals the from -> to 's state, it can be eat or no eat or cannot move.
 *
 * Luna Row & Column Map（位行位列 走法状态映射）
 * the third dimension indicates the target index, so the second dimension and third dimension can indicates the state of the index of rook to the target index.
 * so I can ask, is index to target index is rook eat? cannon eat? super cannon eat? eat nothing? or it cannot move to target index.
 */
typedef struct {
	Bool K[LCBoardMapLength]; // [256][256]
	Bool A[LCBoardMapLength];
	Bool P[LCBoardMapLength << 1]; // [2][256][256]
	
	LCLocation B[LCBoardMapLength]; // whitch can also be B's leg map.
	LCLocation N[LCBoardMapLength]; // whitch can also be N's leg map.
	
	LCRowColumnMapState Row[1 << 20]; // [2 ^ 12][2 ^ 4][2 ^ 4]
	LCRowColumnMapState Column[1 << 21]; // [2 ^ 13][2 ^ 4][2 ^ 4]
	
	LCRowColumnMapState Nan;
	LCRowColumnMapState EatNone;
	LCRowColumnMapState EatR;
	LCRowColumnMapState EatC;
	LCRowColumnMapState EatSuperC;
	
	LCRowColumnMapState MaskR;
	LCRowColumnMapState MaskC;
} LCMoveMap;

extern const LCMoveMap *const LCMoveMapConstRef;

LC_INLINE LCRowColumnMapState LCMoveMapGetRowMapState(const LCRowColumn rank, const LCRowColumnIndex from, const LCRowColumnIndex to) {
	return *(LCMoveMapConstRef->Row + (rank << 8) + (from << 4) + to);
}

LC_INLINE LCRowColumnMapState LCMoveMapGetColumnMapState(const LCRowColumn rank, const LCRowColumnIndex from, const LCRowColumnIndex to) {
	return *(LCMoveMapConstRef->Column + (rank << 8) + (from << 4) + to);
}

// MARK: - Zobrist 散列
typedef UInt32 LCZobristHash;
typedef UInt64 LCZobristKey;

extern const LCChess LCZobristMap[LCChessLength];
extern const LCZobristHash *const LCZobristConstHash;
extern const LCZobristKey *const LCZobristConstKey;

LC_INLINE UInt16 LCChessGetZobristOffset(const LCChess chess, const LCLocation location) {
    return (LCZobristMap[chess] << 8) | location;
}

// MARK: - Luna Init PreGenerate.（走法预生成 计算）
extern void LCInitPreGenerate(void);
