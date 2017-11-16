//
//  Luna.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna.h"
#import "Luna+C.h"

// MARK: - Board Operation.
@interface Luna() {
	Luna_Location _board[256];
	Luna_Location _chess[48];
	Luna_Side _side;
	Luna_Move _lastMove;
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
	return _lastMove;
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
	_lastMove = 0;
	
	_state = LunaBoardStateRedPlayer;
	_isThinking = NO;
}

- (Luna_Chess)makeMoveWithMove:(Luna_Move)move {
	const Luna_Location from = move >> 8;
	const Luna_Location to = move & 0xff;
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
}

- (void)undoMoveWithMove:(Luna_Move)move ate:(Luna_Chess)ate {
	const Luna_Location from = move >> 8;
	const Luna_Location to = move & 0xff;
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

- (BOOL)isCheckMate;

- (BOOL)isCheck;

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

- (BOOL)isCheckMate {
	return NO;
}

- (BOOL)isCheck {
	return NO;
}

- (BOOL)isLegalStateWithMove:(Luna_Location)from to:(Luna_Location)to {
	// eat check.
	if (_board[to] && !Luna_IsNotSameSide(_board[to], _side)) {
		return NO;
	}
	return YES;
}

// Gernerate Moves
- (void)K_GenerateWithParameters:(NSArray *)parameters {
	Luna_Location from = [parameters.firstObject unsignedIntValue];
	NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
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
	Luna_Location from = [parameters.firstObject unsignedIntValue];
	NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
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
	Luna_Location from = [parameters.firstObject unsignedIntValue];
	NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
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
	Luna_Location from = [parameters.firstObject unsignedIntValue];
	NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
	for (Luna_Location *to = Luna_MoveArray_N + (from << 3), *end = to + 8; to < end; to++) {
		if (*to) {
			if ( !_board[Luna_MoveMap_N[(from << 8) + *to]] && [self isLegalStateWithMove:from to:*to]) {
				[moves addObject:@(*to)];
			}
		} else {
			break;
		}
	}
}

- (void)R_GenerateWithParameters:(NSArray *)parameters {
	
}

- (void)C_GenerateWithParameters:(NSArray *)parameters {
	
}

- (void)P_GenerateWithParameters:(NSArray *)parameters {
	Luna_Location from = [parameters.firstObject unsignedIntValue];
	NSMutableArray<NSNumber *> *moves = [parameters lastObject];
	
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

@end

// MARK: - Game.
@implementation Luna (Game)

- (void)initBoardWithFEN:(NSString *)FEN {
	
}

- (BOOL)isAnotherChoiceWithLocation:(Luna_Location)location {
	NSAssert(Luna_LegalLocation_Board[location] == 1, @"%s: location is not legal", __FUNCTION__);
	
	Luna_Chess chess = _board[location];
	return chess && !Luna_IsNotSameSide(chess, _side);
}

- (NSArray<NSNumber *> *)legalMovesWithLocation:(Luna_Location)location {
	return [self generateMovesWithLocation:location];
}

- (LunaMoveState)moveChessWithMove:(Luna_Move)move {
	[self makeMoveWithMove:move];
	[self oppositeSide];
	_lastMove = move;
	return LunaMoveStateEatCheck;
}

@end
