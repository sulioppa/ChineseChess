//
//  Luna.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna.h"
#import "Luna+C.h"
#import "Luna+Objc.h"

// MARK: - Board Operation.
@interface Luna() {
	Luna_Location _board[256];
	Luna_Location _chess[48];
	Luna_Side _side;
	
	id<LunaCoding> _coder;
	LunaRecordStack *_stack;
}

- (void)initBoard;

- (Luna_Chess)makeMoveWithMove:(Luna_Move)move;

- (void)oppositeSide;

- (void)undoMoveWithMove:(Luna_Move)move ate:(Luna_Chess)ate;

@end

@implementation Luna

// Read only properties
- (NSArray<NSNumber *> *)chesses {
	NSMutableArray<NSNumber *> *array = [NSMutableArray array];
	for (Luna_Chess i = 16; i < 48; i++) {
		[array addObject:@(_chess[i])];
	}
	return [NSArray arrayWithArray:array];
}

- (Luna_Move)lastMove {
	return _stack.peek.move;
}

// Board Operation
- (instancetype)init
{
	self = [super init];
	if (self) {
		[self initBoard];
	}
	return self;
}

- (void)initBoard {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Luna_Init_PreGenerate();
	});
	
	memcpy(_board, Luna_InitBoard, 256);
	memcpy(_chess, Luna_InitChess, 48);
	_side = 0;
	
	_coder = [LunaFENCoder new];
	_stack = [[LunaRecordStack alloc] initWithCoder:_coder];
	
	_state = LunaBoardStateTurnRedSide;
	_characterRecords = [NSMutableArray array];
	self.isThinking = NO;
}

- (Luna_Chess)makeMoveWithMove:(Luna_Move)move {
	const Luna_Location from = Luna_MoveFrom(move);
	const Luna_Location to = Luna_MoveTo(move);
	const Luna_Chess ate = _board[to];
	const Luna_Chess chess = _board[from];
	
	_chess[chess] = to;
	_chess[ate] = 0;
	_board[from] = 0;
	_board[to] = chess;
	return ate;
}

- (void)oppositeSide {
	_side = 1 - _side;
	_state =  _side;
}

- (void)undoMoveWithMove:(Luna_Move)move ate:(Luna_Chess)ate {
	const Luna_Location from = Luna_MoveFrom(move);
	const Luna_Location to = Luna_MoveTo(move);
	const Luna_Chess chess = _board[to];
	
	_chess[chess] = from;
	_board[from] = chess;
	_board[to] = ate;
	if (ate) {
		_chess[ate] = to;
	}
}

@end

// MARK: - AI.
@interface Luna (AI)

- (NSArray<NSNumber *> *)generateMovesWithLocation:(Luna_Location)location;

- (BOOL)isCheckedMateWithTargetSide:(BOOL)isRed;

- (BOOL)isCheckedWithTargetSide:(BOOL)isRed;

- (Luna_Chess)catchWithLocation:(Luna_Location)location hasEat:(BOOL)has;

@end

@implementation Luna (AI)

- (NSArray<NSNumber *> *)generateMovesWithLocation:(Luna_Location)location {
	NSAssert(_board[location] != 0, @"%s: the chess at location is not exist.", __FUNCTION__);
	
	const SEL selectors[16] = {
		@selector(K_GenerateWithParameters:),
		@selector(A_GenerateWithParameters:), @selector(A_GenerateWithParameters:),
		@selector(B_GenerateWithParameters:), @selector(B_GenerateWithParameters:),
		@selector(N_GenerateWithParameters:), @selector(N_GenerateWithParameters:),
		@selector(R_GenerateWithParameters:), @selector(R_GenerateWithParameters:),
		@selector(C_GenerateWithParameters:), @selector(C_GenerateWithParameters:),
		@selector(P_GenerateWithParameters:), @selector(P_GenerateWithParameters:), @selector(P_GenerateWithParameters:), @selector(P_GenerateWithParameters:), @selector(P_GenerateWithParameters:)
	};
	
	NSMutableArray<NSNumber *> *moves = [NSMutableArray array];
	[self performSelectorOnMainThread:selectors[_board[location] & 15] withObject:@[ @(location), moves ] waitUntilDone:YES];
	return [NSArray arrayWithArray:moves];
}

// MARK: - Gernerate Moves
- (void)K_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_K + (from << 2), *end = to + 4; to < end; to++) {
		if (*to) {
			if ([self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

- (void)A_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_A + (from << 2), *end = to + 4; to < end; to++) {
		if (*to) {
			if ([self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

- (void)B_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_B + (from << 2), *end = to + 4; to < end; to++) {
		if (*to) {
			if ( !_board[(from + *to) >> 1] && [self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

- (void)N_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_N + (from << 3), *end = to + 8; to < end; to++) {
		if (*to) {
			if ( !_board[Luna_MoveMap_N[Luna_MoveMake(from, *to)]] && [self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

- (void)R_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	const void (^ add)(uint8_t) = ^(uint8_t to) {
		if ([self isLegalStateWithMove:from to:to]) {
			[moves addObject:@(to)];
		}
	};
	
	// Row
	uint16_t rank = [self rankWithLocation:from isRow:YES];
	const int8_t *offset= Luna_Bit(true, rank, from & 15, Luna_BitOffset_EatR);
	if (*offset) {
		add(from + *offset);
	}
	
	offset++;
	if (*offset) {
		add(from + *offset);
	}
	
	offset = Luna_Bit(true, rank, from & 15, Luna_BitOffset_EatNone);
	if (*offset) {
		for (Luna_Location to = from + *offset; to < from; to++) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (Luna_Location to = from + *offset; to > from; to--) {
			add(to);
		}
	}
	
	// Column
	rank = [self rankWithLocation:from isRow:NO];
	offset= Luna_Bit(false, rank, from >> 4, Luna_BitOffset_EatR);
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset++;
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset = Luna_Bit(false, rank, from >> 4, Luna_BitOffset_EatNone);
	if (*offset) {
		for (Luna_Location to = from + (*offset << 4); to < from; to += 16) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (Luna_Location to = from + (*offset << 4); to > from; to -= 16) {
			add(to);
		}
	}
}

- (void)C_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	const void (^ add)(uint8_t) = ^(uint8_t to) {
		if ([self isLegalStateWithMove:from to:to]) {
			[moves addObject:@(to)];
		}
	};
	
	// Row
	uint16_t rank = [self rankWithLocation:from isRow:YES];
	const int8_t *offset= Luna_Bit(true, rank, from & 15, Luna_BitOffset_EatC);
	if (*offset) {
		add(from + *offset);
	}
	
	offset++;
	if (*offset) {
		add(from + *offset);
	}
	
	offset = Luna_Bit(true, rank, from & 15, Luna_BitOffset_EatNone);
	if (*offset) {
		for (Luna_Location to = from + *offset; to < from; to++) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (Luna_Location to = from + *offset; to > from; to--) {
			add(to);
		}
	}
	
	// Column
	rank = [self rankWithLocation:from isRow:NO];
	offset= Luna_Bit(false, rank, from >> 4, Luna_BitOffset_EatC);
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset++;
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset = Luna_Bit(false, rank, from >> 4, Luna_BitOffset_EatNone);
	if (*offset) {
		for (Luna_Location to = from + (*offset << 4); to < from; to += 16) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (Luna_Location to = from + (*offset << 4); to > from; to -= 16) {
			add(to);
		}
	}
}

- (void)P_GenerateWithParameters:(NSArray *)parameters {
	const Luna_Location from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_P + (from << 2) + (_side << 10), *end = to + 3; to < end; to++) {
		if (*to) {
			if ([self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

// MARK: - Attacks Check
- (BOOL)N_AttackWithLocation:(Luna_Location)location target:(Luna_Location)target {
	Luna_Location leg = Luna_MoveMap_N[Luna_MoveMake(location, target)];
	return leg && _board[leg] == 0;
}

- (BOOL)R_AttackWithLocation:(Luna_Location)location target:(Luna_Location)target {
	if (Luna_IsSameRow(location, target)) {
		return Luna_Map(true, [self rankWithLocation:location isRow:YES], Luna_Column(location), Luna_Column(target)) == LunaRowColumnMapStateEatR;
	}
	
	if (Luna_IsSameColumn(location, target)) {
		return Luna_Map(false, [self rankWithLocation:location isRow:NO], Luna_Row(location), Luna_Row(target)) == LunaRowColumnMapStateEatR;
	}
	
	return NO;
}

- (BOOL)C_AttackWithLocation:(Luna_Location)location target:(Luna_Location)target {
	if (Luna_IsSameRow(location, target)) {
		return Luna_Map(true, [self rankWithLocation:location isRow:YES], Luna_Column(location), Luna_Column(target)) == LunaRowColumnMapStateEatC;
	}
	
	if (Luna_IsSameColumn(location, target)) {
		return Luna_Map(false, [self rankWithLocation:location isRow:NO], Luna_Row(location), Luna_Row(target)) == LunaRowColumnMapStateEatC;
	}
	
	return NO;
}

- (BOOL)P_AttackWithLocation:(Luna_Location)location target:(Luna_Location)target {
	uint8_t isBlack = (_board[location] >> 4) > 1;
	return Luna_MoveMap_P[Luna_MoveMake(location, target) + (isBlack << 16)];
}

// MARK: - Function
- (BOOL)isCheckedMateWithTargetSide:(BOOL)isBlack {
	for (uint8_t start = 16 + (isBlack << 4), end = start + 16; start < end; start++) {
		if (_chess[start] && [self generateMovesWithLocation:_chess[start]].count) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isCheckedWithTargetSide:(BOOL)isBlack {
	const Luna_Location kingLocation =  _chess[16 + (isBlack << 4)];

	for (uint8_t start = 21 + ((1- isBlack) << 4), end = start + 11; start < end; start++) {
		if (_chess[start] == 0) continue;
		
		switch (start) {
			case 21: case 22: case 37: case 38: // N
				if ([self N_AttackWithLocation:_chess[start] target:kingLocation]) {
					return YES;
				}
				break;
				
			case 23: case 24: case 39: case 40: // R
				if ([self R_AttackWithLocation:_chess[start] target:kingLocation]) {
					return YES;
				}
				break;
				
			case 25: case 26: case 41: case 42: // C
				if ([self C_AttackWithLocation:_chess[start] target:kingLocation]) {
					return YES;
				}
				break;
				
			default: // P
				if ([self P_AttackWithLocation:_chess[start] target:kingLocation]) {
					return YES;
				}
		}
	}
	
	return NO;
}

- (BOOL)isFaceToFace {
	if (Luna_IsSameColumn(_chess[16], _chess[32])) {
		return Luna_Map(false, [self rankWithLocation:_chess[16] isRow:false], Luna_Row(_chess[16]), Luna_Row(_chess[32])) == LunaRowColumnMapStateEatR;
	}
	
	return NO;
}

- (BOOL)isLegalStateWithMove:(Luna_Location)from to:(Luna_Location)to {
	// eat check.
	if (_board[to] && !Luna_IsNotSameSide(_board[to], _side)) {
		return NO;
	}
	
	Luna_Chess ate = [self makeMoveWithMove:Luna_MoveMake(from, to)];
	
	// face check and other attack check
	BOOL isIllegal = [self isFaceToFace] || [self isCheckedWithTargetSide:_side];
	
	[self undoMoveWithMove:Luna_MoveMake(from, to) ate:ate];
	
	return !isIllegal;
}

- (Luna_Chess)catchWithLocation:(Luna_Location)location hasEat:(BOOL)has {
    if (has) {
        return 0;
    }
    
    return 0;
}

- (uint16_t)rankWithLocation:(Luna_Location)location isRow:(BOOL)isRow {
	uint16_t rank = 0;
	
	void (^ setRank)(uint16_t *, uint8_t, BOOL) = ^(uint16_t *rank, uint8_t idx, BOOL isOne) {
		if (isOne) {
			*rank |= (1 << idx);
		} else {
			*rank &= ~(1 << idx);
		}
	};
	
	if (isRow) {
		for (uint8_t min = (location >> 4) << 4, max = min + 16, location = min; location < max; location++) {
			setRank(&rank, location - min, _board[location]);
		}
	} else {
		for (uint16_t min = location & 15, location = min; location < 255; location += 16) {
			setRank(&rank ,(location - min) >> 4, _board[location]);
		}
	}
	
	return rank;
}

@end

// MARK: - Game.
@implementation Luna (Game)

- (BOOL)isAnotherChoiceWithLocation:(Luna_Location)location {
	NSAssert(Luna_LegalLocation_Board[location] == 1, @"%s: location is not legal", __FUNCTION__);
	
	Luna_Chess chess = _board[location];
	return chess && !Luna_IsNotSameSide(chess, _side);
}

- (NSArray<NSNumber *> *)legalMovesWithLocation:(Luna_Location)location {
	return [self generateMovesWithLocation:location];
}

- (LunaMoveState)moveChessWithMove:(Luna_Move)move {
	[_characterRecords addObject:[LunaRuler characterRecordWithMove:move board:_board]];
	
	LunaRecord *record = [LunaRecord new];
	record.code = [_coder encode:_board];
	record.move = move;
	record.chess = _board[Luna_MoveFrom(move)];
	record.eat = [self makeMoveWithMove:move];
	record.position = [_coder encode:_board];
	record.catch = [self catchWithLocation:Luna_MoveTo(move) hasEat:record.eat];
	[_stack push:record];
	
	[self oppositeSide];
	
	LunaMoveState state = record.eat ? LunaMoveStateEat : LunaMoveStateNormal;
	
	if ([self isCheckedMateWithTargetSide:_side]) {
		state =  record.eat ? LunaMoveStateEatCheckMate : LunaMoveStateCheckMate;
		_state =  _side ? LunaBoardStateWinNormalRed : LunaBoardStateWinNormalBlack;
	} else if ([self isCheckedWithTargetSide:_side]) {
		state =  record.eat ? LunaMoveStateEatCheck : LunaMoveStateCheck;
	}

	if ((_state & 0xfe) == 0) {
		_state = [LunaRuler analyzeWithRecords:_stack.allRecords currentSide:_side];
	}
	return state;
}

- (Luna_Chess)regretWithMove:(Luna_Move *)move {
	LunaRecord *record = [_stack pop];
	
	if (record) {
		[_characterRecords removeLastObject];
		[self undoMoveWithMove:record.move ate:record.eat];
		[self oppositeSide];
		
		*move = record.move;
		return record.eat;
	} else {
		*move = 0;
		return 0;
	}
}

@end

// MARK: - History
@implementation Luna (History)

- (void)initBoardWithFile:(NSString *)file {
    memcpy(_board, Luna_InitBoard, 256);
    memcpy(_chess, Luna_InitChess, 48);
    _side = 0;
    
    _state = LunaBoardStateTurnRedSide;
    [_characterRecords removeAllObjects];
    self.isThinking = NO;
    
    if (file == nil) {
        [_stack clear];
        return;
    }
    
    _side = _stack.firstSide;
    _state =  _side;
    [_coder decode:_stack.firstCode board:_board];
    
    memset(_chess, 0, 48);
    for (int i = 0; i < 256; i++) {
        if (_board[i]) {
            _chess[_board[i]] = i;
        }
    }
    
    for (LunaRecord *record in _stack.allRecords) {
        [_characterRecords addObject:[LunaRuler characterRecordWithMove:record.move board:_board]];
        
        record.chess = _board[Luna_MoveFrom(record.move)];
        record.eat = [self makeMoveWithMove:record.move];
        record.position = [_coder encode:_board];
        record.catch = [self catchWithLocation:Luna_MoveTo(record.move) hasEat:record.eat];
        
        _side = 1 - _side;
    }
    
    if ([self isCheckedMateWithTargetSide:_side]) {
        _state =  _side ? LunaBoardStateWinNormalRed : LunaBoardStateWinNormalBlack;
    }
    
    if ((_state & 0xfe) == 0) {
        _state = [LunaRuler analyzeWithRecords:_stack.allRecords currentSide:_side];
    }
}

- (NSString *)historyFile {
    return [_stack historyFileWithCode:NO];
}

@end
