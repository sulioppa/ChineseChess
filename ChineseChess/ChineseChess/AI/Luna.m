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

// MARK: - AI Luna.
@interface Luna() {
	LunaLocation _board[256];
	LunaLocation _chess[48];
	BOOL _side;
	
	id<LunaCoding> _coder;
	LunaRecordStack *_stack;
}

- (void)initBoard;

- (LunaChess)doMoveWithMove:(LunaMove)move;

- (void)oppositeSide;

- (void)undoMoveWithMove:(LunaMove)move ate:(LunaChess)ate;

@end

@implementation Luna

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self initBoard];		
	}
	return self;
}

// Read only properties
- (NSArray<NSNumber *> *)chesses {
	NSMutableArray<NSNumber *> *array = [NSMutableArray array];
	
	for (LunaChess i = 16; i < 48; i++) {
		[array addObject:@(_chess[i])];
	}
	
	return [NSArray arrayWithArray:array];
}

// Board Operation
- (void)initBoard {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Luna_Init_PreGenerate();
	});
	
	memcpy(_board, Luna_InitBoard, 256);
	memcpy(_chess, Luna_InitChess, 48);
	_side = NO;
	
	_coder = [LunaFENCoder new];
	_stack = [[LunaRecordStack alloc] initWithCoder:_coder];
	_state = LunaBoardStateTurnRedSide;
	
	self.isThinking = NO;
}

- (LunaChess)doMoveWithMove:(LunaMove)move {
	const LunaLocation from = Luna_MoveFrom(move);
	const LunaLocation to = Luna_MoveTo(move);
	const LunaChess ate = _board[to];
	const LunaChess chess = _board[from];
	
	_chess[chess] = to;
	_chess[ate] = 0;
	_board[from] = 0;
	_board[to] = chess;
	return ate;
}

- (void)oppositeSide {
	_side = !_side;
	_state =  _side;
}

- (void)undoMoveWithMove:(LunaMove)move ate:(LunaChess)ate {
	const LunaLocation from = Luna_MoveFrom(move);
	const LunaLocation to = Luna_MoveTo(move);
	const LunaChess chess = _board[to];
	
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

- (NSArray<NSNumber *> *)generateMovesWithLocation:(LunaLocation)location;

- (BOOL)isCheckedMateWithTargetSide:(BOOL)isBlack;

- (BOOL)isCheckedWithTargetSide:(BOOL)isBlack;

- (LunaChess)catchWithChess:(LunaChess)chess targetChess:(LunaChess)target hasEat:(BOOL)has;

- (uint32_t)bitChess;

- (BOOL)isLegalWithChess:(LunaChess)chess atLocation:(LunaLocation)location;

@end

@implementation Luna (AI)

// MARK: - Gernerate Moves
- (void)K_GenerateWithParameters:(NSArray *)parameters {
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (LunaLocation *to = Luna_MoveArray_K + (from << 2), *end = to + 4; to < end; to++) {
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
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (LunaLocation *to = Luna_MoveArray_A + (from << 2), *end = to + 4; to < end; to++) {
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
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (LunaLocation *to = Luna_MoveArray_B + (from << 2), *end = to + 4; to < end; to++) {
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
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (LunaLocation *to = Luna_MoveArray_N + (from << 3), *end = to + 8; to < end; to++) {
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
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
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
		for (LunaLocation to = from + *offset; to < from; to++) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (LunaLocation to = from + *offset; to > from; to--) {
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
		for (LunaLocation to = from + (*offset << 4); to < from; to += 16) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (LunaLocation to = from + (*offset << 4); to > from; to -= 16) {
			add(to);
		}
	}
}

- (void)C_GenerateWithParameters:(NSArray *)parameters {
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
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
		for (LunaLocation to = from + *offset; to < from; to++) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (LunaLocation to = from + *offset; to > from; to--) {
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
		for (LunaLocation to = from + (*offset << 4); to < from; to += 16) {
			add(to);
		}
	}
	
	offset++;
	if (*offset) {
		for (LunaLocation to = from + (*offset << 4); to > from; to -= 16) {
			add(to);
		}
	}
}

- (void)P_GenerateWithParameters:(NSArray *)parameters {
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (LunaLocation *to = Luna_MoveArray_P + (from << 2) + (Luna_Side(_board[from]) << 10), *end = to + 3; to < end; to++) {
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
- (BOOL)K_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	return Luna_MoveMap_K[Luna_MoveMake(location, target)];
}

- (BOOL)A_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	return Luna_MoveMap_A[Luna_MoveMake(location, target)];
}

- (BOOL)B_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	LunaLocation leg = Luna_MoveMap_B[Luna_MoveMake(location, target)];
	return leg && _board[leg] == 0;
}

- (BOOL)N_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	LunaLocation leg = Luna_MoveMap_N[Luna_MoveMake(location, target)];
	return leg && _board[leg] == 0;
}

- (BOOL)R_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	if (Luna_IsSameRow(location, target)) {
		return Luna_Map(true, [self rankWithLocation:location isRow:YES], Luna_Column(location), Luna_Column(target)) == LunaRowColumnMapStateEatR;
	}
	
	if (Luna_IsSameColumn(location, target)) {
		return Luna_Map(false, [self rankWithLocation:location isRow:NO], Luna_Row(location), Luna_Row(target)) == LunaRowColumnMapStateEatR;
	}
	
	return NO;
}

- (BOOL)C_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	if (Luna_IsSameRow(location, target)) {
		return Luna_Map(true, [self rankWithLocation:location isRow:YES], Luna_Column(location), Luna_Column(target)) == LunaRowColumnMapStateEatC;
	}
	
	if (Luna_IsSameColumn(location, target)) {
		return Luna_Map(false, [self rankWithLocation:location isRow:NO], Luna_Row(location), Luna_Row(target)) == LunaRowColumnMapStateEatC;
	}
	
	return NO;
}

- (BOOL)P_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	return Luna_MoveMap_P[Luna_MoveMake(location, target) + (Luna_Side(_board[location]) << 16)];
}

// MARK: - Public
- (NSArray<NSNumber *> *)generateMovesWithLocation:(LunaLocation)location {
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

- (BOOL)isCheckedMateWithTargetSide:(BOOL)isBlack {
	for (uint8_t start = Luna_King(isBlack), end = start + 16; start < end; start++) {
		if (_chess[start] && [self generateMovesWithLocation:_chess[start]].count) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isCheckedWithTargetSide:(BOOL)isBlack {
	const LunaLocation kingLocation =  _chess[Luna_King(isBlack)];

	for (uint8_t start = 21 + ((1- isBlack) << 4), end = start + 11; start < end; start++) {
		if ([self isAttackWithFrom:_chess[start] to:kingLocation includeKAB:NO]) {
			return YES;
		}
	}
	
	return NO;
}

- (LunaChess)catchWithChess:(LunaChess)chess targetChess:(LunaChess)target hasEat:(BOOL)has {
    if (has) {
        return 0;
    }

	if ([self isCheckedWithTargetSide:Luna_Side(target)]) {
		return Luna_King(Luna_Side(target));
	}
	
	// catch the last move's chess (no real protected) ?
	if (target == 0 || ![self didCatchWithChess:chess target:target]) {
		return 0;
	}

    return target;
}

- (uint32_t)bitChess {
	void (^ setBit)(uint32_t *, uint8_t, BOOL) = ^(uint32_t *bit, uint8_t idx, BOOL isOne) {
		if (isOne) {
			*bit |= (1 << idx);
		} else {
			*bit &= ~(1 << idx);
		}
	};
	
	uint32_t bit = 0;
	for (int index = 16; index < 48; index++) {
		setBit(&bit, index - 16, _chess[index]);
	}
	
	return bit;
}

- (BOOL)isLegalWithChess:(LunaChess)chess atLocation:(LunaLocation)location {
	switch (chess) {
		case 16: // K
			return Luna_LegalLocation_K[location] && location > Luna_RiverEdge;
		case 32:
			return Luna_LegalLocation_K[location] && location < Luna_RiverEdge;
			
		case 17: case 18: // A
			return Luna_LegalLocation_A[location] && location > Luna_RiverEdge;
		case 33: case 34:
			return Luna_LegalLocation_A[location] && location < Luna_RiverEdge;
			
		case 19: case 20: // B
			return Luna_LegalLocation_B[location] && location > Luna_RiverEdge;
		case 35: case 36:
			return Luna_LegalLocation_B[location] && location < Luna_RiverEdge;
		
		case 27: case 28: case 29: case 30: case 31: case 43: case 44: case 45: case 46: case 47: // P
			return Luna_LegalLocation_P[location + (Luna_Side(chess) << 8)];
		
		default: // NRC
			return YES;
	}
}

// MARK: - Private
- (BOOL)isFaceToFace {
	if (Luna_IsSameColumn(_chess[16], _chess[32])) {
		return Luna_Map(false, [self rankWithLocation:_chess[16] isRow:false], Luna_Row(_chess[16]), Luna_Row(_chess[32])) == LunaRowColumnMapStateEatR;
	}
	
	return NO;
}

- (BOOL)isLegalStateWithMove:(LunaLocation)from to:(LunaLocation)to {
	// eat check.
	if (_board[to] && !Luna_IsNotSameArmy(_board[from], _board[to])) {
		return NO;
	}
	
	LunaChess ate = [self doMoveWithMove:Luna_MoveMake(from, to)];
	
	// face check and other attack check
	BOOL isIllegal = [self isFaceToFace] || [self isCheckedWithTargetSide:Luna_Side(_board[to])];
	
	[self undoMoveWithMove:Luna_MoveMake(from, to) ate:ate];
	
	return !isIllegal;
}

- (BOOL)isAttackWithFrom:(LunaLocation)from to:(LunaLocation)to includeKAB:(BOOL)include {
	switch (_board[from]) {
		case 16: case 32: // K
			return include && [self K_AttackWithLocation:from target:to];
			
		case 17: case 18: case 33: case 34: // A
			return include && [self A_AttackWithLocation:from target:to];
			
		case 19: case 20: case 35: case 36: // B
			return include && [self B_AttackWithLocation:from target:to];
			
		case 21: case 22: case 37: case 38: // N
			return [self N_AttackWithLocation:from target:to];
			
		case 23: case 24: case 39: case 40: // R
			return [self R_AttackWithLocation:from target:to];
			
		case 25: case 26: case 41: case 42: // C
			return [self C_AttackWithLocation:from target:to];
			
		case 27: case 28: case 29: case 30: case 31: case 43: case 44: case 45: case 46: case 47: // P
			return [self P_AttackWithLocation:from target:to];
		
		default:
			return NO;
	}
}

- (BOOL)didCatchWithChess:(LunaChess)chess target:(LunaChess)target {
	if ([self isAttackWithFrom:_chess[chess] to:_chess[target] includeKAB:NO] && [self isLegalStateWithMove:_chess[chess] to:_chess[target]]) {
		LunaMove move = Luna_MoveMake(_chess[chess], _chess[target]);
		LunaChess ate = [self doMoveWithMove:move];
		
		BOOL hasProtection = [self isUnderAttackWithTarget:chess];
		
		[self undoMoveWithMove:move ate:ate];
		return !hasProtection;
	}
	
	return NO;
}

- (BOOL)isUnderAttackWithTarget:(LunaChess)chess {
	for (uint8_t start = Luna_King(1 - Luna_Side(chess)), end = start + 16; start < end; start++) {
		if ([self isAttackWithFrom:_chess[start] to:_chess[chess] includeKAB:YES] && [self isLegalStateWithMove:_chess[start] to:_chess[chess]]) {
			return YES;
		}
	}
	
	return NO;
}

- (uint16_t)rankWithLocation:(LunaLocation)location isRow:(BOOL)isRow {
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
		for (uint16_t min = location & 15, location = min; location < 256; location += 16) {
			setRank(&rank ,(location - min) >> 4, _board[location]);
		}
	}
	
	return rank;
}

@end

// MARK: - Game.
@implementation Luna (Game)

- (LunaRecord *)lastMove {
	return [_stack peek];
}

- (BOOL)isAnotherChoiceWithLocation:(LunaLocation)location {
	NSAssert(Luna_LegalLocation_Board[location] == 1, @"%s: location is not legal", __FUNCTION__);
	
	LunaChess chess = _board[location];
	return chess && !Luna_IsNotSameSide(chess, _side);
}

- (NSArray<NSNumber *> *)legalMovesWithLocation:(LunaLocation)location {
	return [self generateMovesWithLocation:location];
}

- (LunaMoveState)moveChessWithMove:(LunaMove)move {
	LunaRecord *record = [LunaRecord new];
	
	record.code = [_coder encode:_board];
	[record setCharacter:[LunaRecordCharacter characterRecordWithMove:move board:_board array:_chess] count:_stack.count];
	
	record.chess = _board[Luna_MoveFrom(move)];
	record.move = move;
	record.eat = [self doMoveWithMove:move];
	
	record.position = [_coder encode:_board];
	record.catch = [self catchWithChess:record.chess targetChess:_stack.peek.chess hasEat:record.eat];
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
		_state = [LunaRecordRuler analyzeWithRecords:_stack.allRecords currentSide:_side chesses:self.bitChess];
	}
	return state;
}

- (LunaChess)regretWithMove:(LunaMove *)move {
	NSAssert(move != nil, @"%s: move should not be nil", __FUNCTION__);
	LunaRecord *record = [_stack pop];
	
	if (record) {
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

- (NSArray<LunaRecord *> *)records {
	return [_stack allRecords];
}

- (NSUInteger)count {
	return _stack.count;
}

- (LunaRecord *)recordAtIndex:(NSUInteger)idx {
	return _stack[idx];
}

- (NSString *)characters {
	return [_stack characters];
}

- (void)initBoardWithFile:(NSString *)file {
    memcpy(_board, Luna_InitBoard, 256);
    memcpy(_chess, Luna_InitChess, 48);
    _side = NO;
    
    _state = LunaBoardStateTurnRedSide;
    self.isThinking = NO;
    
    if (file == nil) {
        [_stack clear];
        return;
	} else {
		[_stack reloadWith:file];
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
	
	__block LunaRecord *last;
	
	[_stack.allRecords enumerateObjectsUsingBlock:^(LunaRecord *record, NSUInteger idx, BOOL *stop) {
		record.code = [_coder encode:_board];
		[record setCharacter:[LunaRecordCharacter characterRecordWithMove:record.move board:_board array:_chess] count:idx];
		
		record.chess = _board[Luna_MoveFrom(record.move)];
		record.eat = [self doMoveWithMove:record.move];
		
		record.position = [_coder encode:_board];
		record.catch = [self catchWithChess:record.chess targetChess:last.chess hasEat:record.eat];
		
		[self oppositeSide];
		last = record;
	}];
	
    if ([self isCheckedMateWithTargetSide:_side]) {
        _state =  _side ? LunaBoardStateWinNormalRed : LunaBoardStateWinNormalBlack;
    }
    
    if ((_state & 0xfe) == 0) {
        _state = [LunaRecordRuler analyzeWithRecords:_stack.allRecords currentSide:_side chesses:self.bitChess];
    }
}

- (NSString *)historyFile {
    return [_stack historyFileWithCode:NO];
}

@end

// MARK: - Edit
@implementation Luna (Edit)

- (NSArray<NSNumber *> *)putChesses {
	NSMutableSet<NSNumber *> *chesses = [NSMutableSet set];
	const LunaChess map[48] = { 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0,0,
		16,
		17, 17,
		19, 19,
		21, 21,
		23, 23,
		25, 25,
		27, 27, 27, 27, 27,
		32,
		33, 33,
		35, 35,
		37, 37,
		39, 39,
		41, 41,
		43, 43, 43, 43, 43
	};
	
	for (int i = 16; i < 48; i++) {
		if (_chess[i] == 0) {
			[chesses addObject:@(map[i])];
		}
	}
	
	return [[chesses allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 unsignedCharValue] < [obj2 unsignedCharValue] ? NSOrderedAscending : NSOrderedDescending;
	}];
}

- (LunaChess)chessAtLocation:(LunaLocation)location {
	return _board[location];
}

- (LunaChess)chessWithExpectedChess:(LunaChess)chess {
	NSAssert(15 < chess && chess < 48 , @"%s: chess must be more than 15 and less than 48", __FUNCTION__);
	
	if ((chess & 15) == 0) {
		NSAssert(NO, @"%s: chess should not be 16 or 32.", __FUNCTION__);
		return chess;
	} else if ((chess & 15) > 10) {
		for (int index = chess > 42 ? 43 : 27, max = index + 5; index < max; index++) {
			if (_chess[index] == 0) {
				return index;
			}
		}
	} else {
		int offset = chess & 1 ? 1 : -1;
		return _chess[chess] == 0 ? chess : chess + offset;
	}
	
	return chess;
}

- (LunaPutChessState)putWithChess:(LunaChess)chess at:(LunaLocation)location {
	chess = [self chessWithExpectedChess:chess];
	if ([self isLegalWithChess:chess atLocation:location]) {
		_board[location] = chess;
		_chess[chess] = location;
		return LunaPutChessStateNormalPut;
	}
	
	return LunaPutChessStateWrongPut;
}

- (LunaPutChessState)moveWithMove:(LunaMove)move {
	LunaLocation from = Luna_MoveFrom(move);
	LunaLocation to = Luna_MoveTo(move);
	
	NSAssert(_board[from], @"%s: board at from: %d should be nonnnull", __FUNCTION__, from);
	if (![self isLegalWithChess:_board[from] atLocation:to]) {
		return LunaPutChessStateWrongPut;
	}
	
	LunaPutChessState isEat = LunaPutChessStateNormalPut;
	
	if (_board[to]) {
		if ([self eraseWithLocation:to] == LunaPutChessStateWrongEat) {
			return LunaPutChessStateWrongEat;
		}
		
		isEat = LunaPutChessStateNormalEat;
	}

	_chess[_board[from]] = to;
	_board[to] = _board[from];
	_board[from] = 0;
	
	return isEat;
}

- (LunaPutChessState)eraseWithLocation:(LunaLocation)location {
	if (_board[location] && _board[location] & 15) {
		_chess[_board[location]] = 0;
		_board[location] = 0;
		return LunaPutChessStateNormalEat;
	}
	
	return LunaPutChessStateWrongEat;
}

- (LunaEditDoneState)isEditDone:(LunaBoardState)state {
	NSAssert(state == LunaBoardStateTurnRedSide || state == LunaBoardStateTurnBlackSide, @"%s:  LunaBoardState: %d is not the expected state.", __FUNCTION__, state);
	
	if ([self isFaceToFace]) {
		return LunaEditDoneStateWrongFaceToFace;
	}
	
	if ([self isCheckedMateWithTargetSide:state]) {
		return LunaEditDoneStateWrongIsCheckedMate;
	}
	
	if ([self isCheckedWithTargetSide:1 - state]) {
		return LunaEditDoneStateWrongCheck;
	}
	
	[_stack clear];
	_stack.firstSide = state;
	_stack.firstCode = [_coder encode:_board];
	
	return LunaEditDoneStateNormal;
}

- (void)resetBoard {
	memcpy(_board, Luna_InitBoard, 256);
	memcpy(_chess, Luna_InitChess, 48);
}

- (void)clearBoard {
	memcpy(_board, Luna_InitBoard, 256);
	memset(_chess, 0, 48);
	
	for (LunaLocation *loc = _board, *max = loc + 256; loc < max; loc++) {
		if (*loc == 0) {
			continue;
		}
		
		if (*loc & 15) {
			*loc = 0;
		} else {
			_chess[*loc] = loc - _board;
		}
	}
}

@end
