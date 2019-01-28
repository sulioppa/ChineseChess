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
	
	id<LunaCoding> _coder;
	LunaRecordStack *_stack;
    
    LunaNextStep *_nextStep;
}

- (void)initBoard;

- (LunaChess)doMoveWithMove:(LunaMove)move;

- (void)oppositeSide;

- (void)undoMoveWithMove:(LunaMove)move ate:(LunaChess)ate;

@end

@interface Luna (AI)

- (NSArray<NSNumber *> *)generateMovesWithLocation:(LunaLocation)location;

- (BOOL)isCheckedMateWithTargetSide:(BOOL)isBlack;

- (BOOL)isCheckedWithTargetSide:(BOOL)isBlack;

- (LunaChess)catchWithChess:(LunaChess)chess targetChess:(LunaChess)target hasEat:(BOOL)has;

- (uint32_t)bitChess;

- (BOOL)isLegalWithChess:(LunaChess)chess atLocation:(LunaLocation)location;

- (NSArray<NSNumber *> *)bannedMoves;

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

- (LunaNextStep *)nextStep {
    if (_nextStep == nil) {
        _nextStep = [LunaNextStep new];
    }
    
    return _nextStep;
}

// Board Operation
- (void)initBoard {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		LCInitPreGenerate();
	});
	
	memcpy(_board, LCInitialDataConst.Board, LCBoardLength);
	memcpy(_chess, LCInitialDataConst.Chess, LCChessLength);
	_side = NO;
	
	_coder = [LunaFENCoder new];
	_stack = [[LunaRecordStack alloc] initWithCoder:_coder];
	_state = LunaBoardStateTurnRedSide;
	
	self.isThinking = NO;
}

- (LunaChess)doMoveWithMove:(LunaMove)move {
	const LunaLocation from = LCMoveGetLocationFrom(move);
	const LunaLocation to = LCMoveGetLocationTo(move);
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
	const LunaLocation from = LCMoveGetLocationFrom(move);
	const LunaLocation to = LCMoveGetLocationTo(move);
	const LunaChess chess = _board[to];
	
	_chess[chess] = from;
	_board[from] = chess;
	_board[to] = ate;
	if (ate) {
		_chess[ate] = to;
	}
}

- (void)nextStepWithDepth:(int)depth block:(void (^)(float progress, LunaMove move))block {
    NSArray *bannedMoves = [self bannedMoves];
    NSString *FEN = [_coder encode:_board];
    Bool side = _side;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        LunaMove move = [LunaRecordVault searchVaultWithFEN:FEN targetSide:side];
        
        if (move) {
            block(1.0, move);
        } else {
            [self.nextStep nextStepWithFEN:FEN
                                  targetSide:side
                                 searchDepth:depth
                                 bannedMoves:bannedMoves
                                  isThinking:&(self->_isThinking)
                                       block:block
             ];
        }
    });
}

@end

// MARK: - AI.
@implementation Luna (AI)

// MARK: - Gernerate Moves
- (void)K_GenerateWithParameters:(NSArray *)parameters {
	const LunaLocation from = [parameters.firstObject unsignedIntValue];
	const NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (const LunaLocation *to = LCMoveArrayConstRef->K + (from << 2), *end = to + 4; to < end; to++) {
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
	
	for (const LunaLocation *to = LCMoveArrayConstRef->A + (from << 2), *end = to + 4; to < end; to++) {
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
	
	for (const LunaLocation *to = LCMoveArrayConstRef->B + (from << 2), *end = to + 4; to < end; to++) {
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
	
	for (const LunaLocation *to = LCMoveArrayConstRef->N + (from << 3), *end = to + 8; to < end; to++) {
		if (*to) {
			if ( !_board[ LCMoveMapConstRef->N[LCMoveMake(from, *to)]] && [self isLegalStateWithMove:from to:*to]) {
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
	const int8_t *offset= LCMoveArrayGetRowOffset(rank, from & 15, LCMoveArrayConstRef->EatR);
	if (*offset) {
		add(from + *offset);
	}
	
	offset++;
	if (*offset) {
		add(from + *offset);
	}
	
	offset = LCMoveArrayGetRowOffset(rank, from & 15, LCMoveArrayConstRef->EatNone);
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
	offset= LCMoveArrayGetColumnOffset(rank, from >> 4, LCMoveArrayConstRef->EatR);
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset++;
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset = LCMoveArrayGetColumnOffset(rank, from >> 4, LCMoveArrayConstRef->EatNone);
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
	const int8_t *offset= LCMoveArrayGetRowOffset(rank, from & 15, LCMoveArrayConstRef->EatC);
	if (*offset) {
		add(from + *offset);
	}
	
	offset++;
	if (*offset) {
		add(from + *offset);
	}
	
	offset = LCMoveArrayGetRowOffset(rank, from & 15, LCMoveArrayConstRef->EatNone);
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
	offset= LCMoveArrayGetColumnOffset(rank, from >> 4, LCMoveArrayConstRef->EatC);
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset++;
	if (*offset) {
		add(from + (*offset << 4));
	}
	
	offset = LCMoveArrayGetColumnOffset(rank, from >> 4, LCMoveArrayConstRef->EatNone);
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
	
	for (const LunaLocation *to = LCMoveArrayConstRef->P + (from << 2) + (LCChessGetSide(_board[from]) << 10), *end = to + 3; to < end; to++) {
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
	return LCMoveMapConstRef->K[LCMoveMake(location, target)];
}

- (BOOL)A_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	return LCMoveMapConstRef->A[LCMoveMake(location, target)];
}

- (BOOL)B_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	LunaLocation leg = LCMoveMapConstRef->B[LCMoveMake(location, target)];
	return leg && _board[leg] == 0;
}

- (BOOL)N_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	LunaLocation leg = LCMoveMapConstRef->N[LCMoveMake(location, target)];
	return leg && _board[leg] == 0;
}

- (BOOL)R_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	if (LCLocationRowIsEqualToLocation(location, target)) {
		return LCMoveMapGetRowMapState([self rankWithLocation:location isRow:YES], LCLocationGetColumn(location), LCLocationGetColumn(target)) == LCMoveMapConstRef->EatR;
	}
	
	if (LCLocationColumnIsEqualToLocation(location, target)) {
		return LCMoveMapGetColumnMapState([self rankWithLocation:location isRow:NO], LCLocationGetRow(location), LCLocationGetRow(target)) == LCMoveMapConstRef->EatR;
	}
	
	return NO;
}

- (BOOL)C_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	if (LCLocationRowIsEqualToLocation(location, target)) {
		return LCMoveMapGetRowMapState([self rankWithLocation:location isRow:YES], LCLocationGetColumn(location), LCLocationGetColumn(target)) == LCMoveMapConstRef->EatC;
	}
	
	if (LCLocationColumnIsEqualToLocation(location, target)) {
		return LCMoveMapGetColumnMapState([self rankWithLocation:location isRow:NO], LCLocationGetRow(location), LCLocationGetRow(target)) == LCMoveMapConstRef->EatC;
	}
	
	return NO;
}

- (BOOL)P_AttackWithLocation:(LunaLocation)location target:(LunaLocation)target {
	return LCMoveMapConstRef->P[LCMoveMake(location, target) + (LCChessGetSide(_board[location]) << 16)];
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
	for (uint8_t start = LCSideGetKing(isBlack), end = start + 16; start < end; start++) {
		if (_chess[start] && [self generateMovesWithLocation:_chess[start]].count) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isCheckedWithTargetSide:(BOOL)isBlack {
	const LunaLocation kingLocation =  _chess[LCSideGetKing(isBlack)];

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
	
	if ([self isCheckedWithTargetSide:LCChessGetSide(target)]) {
		return LCSideGetKing(LCChessGetSide(target));
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
			return LCLegalLocationConst.K[location] && location > LCLegalLocationConst.River;
		case 32:
			return LCLegalLocationConst.K[location] && location < LCLegalLocationConst.River;
			
		case 17: case 18: // A
			return LCLegalLocationConst.A[location] && location > LCLegalLocationConst.River;
		case 33: case 34:
			return LCLegalLocationConst.A[location] && location < LCLegalLocationConst.River;
			
		case 19: case 20: // B
			return LCLegalLocationConst.B[location] && location > LCLegalLocationConst.River;
		case 35: case 36:
			return LCLegalLocationConst.B[location] && location < LCLegalLocationConst.River;
		
		case 27: case 28: case 29: case 30: case 31: case 43: case 44: case 45: case 46: case 47: // P
			return LCLegalLocationConst.P[location + (LCChessGetSide(chess) << 8)];
		
		default: // NRC
			return YES;
	}
}

- (NSArray<NSNumber *> *)bannedMoves {
    NSMutableArray<NSNumber *> *allMoves = [NSMutableArray array];
    
    for (LCChess chess = LCSideGetKing(_side), chessBoundary = chess + 16; chess < chessBoundary; chess++) {
        if (!_chess[chess]) {
            continue;
        }
        
        for (NSNumber *to in [self generateMovesWithLocation:_chess[chess]]) {
            [allMoves addObject:@(LCMoveMake(_chess[chess], [to unsignedCharValue]))];
        }
    }
    
    NSMutableArray<NSNumber *> *bannedMoves = [NSMutableArray array];
    
    for (NSNumber *move in allMoves) {
        if ([self isBannedMove:move]) {
            [bannedMoves addObject:move];
        }
    }
    
    return [bannedMoves copy];
}

// MARK: - Private
- (BOOL)isFaceToFace {
	if (LCLocationColumnIsEqualToLocation(_chess[16], _chess[32])) {
		return LCMoveMapGetColumnMapState([self rankWithLocation:_chess[16] isRow:false], LCLocationGetRow(_chess[16]), LCLocationGetRow(_chess[32])) == LCMoveMapConstRef->EatR;
	}
	
	return NO;
}

- (BOOL)isLegalStateWithMove:(LunaLocation)from to:(LunaLocation)to {
	// eat check.
	if (_board[to] && !LCChessSideIsNotEqualToChess(_board[from], _board[to])) {
		return NO;
	}
	
	LunaChess ate = [self doMoveWithMove:LCMoveMake(from, to)];
	
	// face check and other attack check
	BOOL isIllegal = [self isFaceToFace] || [self isCheckedWithTargetSide:LCChessGetSide(_board[to])];
	
	[self undoMoveWithMove:LCMoveMake(from, to) ate:ate];
	
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
		LunaMove move = LCMoveMake(_chess[chess], _chess[target]);
		LunaChess ate = [self doMoveWithMove:move];
		
		BOOL hasProtection = [self isUnderAttackWithTarget:chess];
		
		[self undoMoveWithMove:move ate:ate];
		return !hasProtection;
	}
	
	return NO;
}

- (BOOL)isUnderAttackWithTarget:(LunaChess)chess {
	for (uint8_t start = LCSideGetKing(1 - LCChessGetSide(chess)), end = start + 16; start < end; start++) {
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

- (BOOL)isBannedMove:(NSNumber *)move {
    BOOL isBanned = NO;
    LCMove aMove;
    
    [self moveChessWithMove:[move unsignedShortValue]];
    
    if (_state == LunaBoardStateWinLongCatchRed || _state == LunaBoardStateWinLongCatchBlack) {
        isBanned = YES;
    }
    
    [self regretWithMove:&aMove];
    return isBanned;
}

@end

// MARK: - Game.
@implementation Luna (Game)

- (LunaRecord *)lastMove {
	return [_stack peek];
}

- (BOOL)isAnotherChoiceWithLocation:(LunaLocation)location {
	NSAssert(LCLegalLocationConst.Board[location] == 1, @"%s: location is not legal", __FUNCTION__);

	LunaChess chess = _board[location];
	return chess && !LCChessSideIsNotSide(chess, _side);
}

- (NSArray<NSNumber *> *)legalMovesWithLocation:(LunaLocation)location {
	return [self generateMovesWithLocation:location];
}

- (LunaMoveState)moveChessWithMove:(LunaMove)move {
	LunaRecord *record = [LunaRecord new];
	
	record.code = [_coder encode:_board];
	[record setCharacter:[LunaRecordCharacter characterRecordWithMove:move board:_board array:_chess] count:_stack.count];
	
	record.chess = _board[LCMoveGetLocationFrom(move)];
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
    memcpy(_board, LCInitialDataConst.Board, LCBoardLength);
    memcpy(_chess, LCInitialDataConst.Chess, LCChessLength);
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
    
    memset(_chess, 0, LCChessLength);
    for (int i = 0; i < LCBoardLength; i++) {
        if (_board[i]) {
            _chess[_board[i]] = i;
        }
    }
	
	__block LunaRecord *last;
	
	const LunaLocation *const board = _board;
	const LunaLocation *const chess = _chess;
	const id<LunaCoding> coder = _coder;
	
	[_stack.allRecords enumerateObjectsUsingBlock:^(LunaRecord *record, NSUInteger idx, BOOL *stop) {
		record.code = [coder encode:board];
		[record setCharacter:[LunaRecordCharacter characterRecordWithMove:record.move board:board array:chess] count:idx];
		
		record.chess = board[LCMoveGetLocationFrom(record.move)];
		record.eat = [self doMoveWithMove:record.move];
		
		record.position = [coder encode:board];
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

- (NSString *)historyFileAt:(NSInteger)idx {
	return [_stack historyFileWithCode:NO at:idx];
}

- (void)moveIndexAt:(NSInteger)idx {
	_stack.currentIndex = idx;
	
	_side = _stack.firstSide;
	_state =  _side;
	[_coder decode:_stack.firstCode board:_board];
	
	memset(_chess, 0, LCChessLength);
	for (int i = 0; i < LCBoardLength; i++) {
		if (_board[i]) {
			_chess[_board[i]] = i;
		}
	}
	
	NSArray<LunaRecord *> *records = _stack.allRecords;
	for (int i = 0; i <= idx; i++) {
		[self doMoveWithMove:records[i].move];
		[self oppositeSide];
	}
}

- (LunaRecord *)currentRecord {
	return _stack.currentRecord;
}

- (LunaRecord *)moveForward {
	LunaRecord *record = [_stack moveForward];
	
	if (record) {
		[self doMoveWithMove:record.move];
		[self oppositeSide];
	}
	return record;
}

- (LunaRecord *)backForward {
	LunaRecord *record = [_stack backForward];
	
	if (record) {
		[self undoMoveWithMove:record.move ate:record.eat];
		[self oppositeSide];
	}
	return record;
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
	LunaLocation from = LCMoveGetLocationFrom(move);
	LunaLocation to = LCMoveGetLocationTo(move);
	
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
	memcpy(_board, LCInitialDataConst.Board, LCBoardLength);
	memcpy(_chess, LCInitialDataConst.Chess, LCChessLength);
}

- (void)clearBoard {
	memcpy(_board, LCInitialDataConst.Board, LCBoardLength);
	memset(_chess, 0, LCChessLength);
	
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
