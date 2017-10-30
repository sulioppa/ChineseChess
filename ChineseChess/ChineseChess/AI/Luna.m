//
//  Luna.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "Luna.h"
#import "Luna+C.h"

@interface Luna() {
	uint8_t _board[256];
	uint8_t _chess[48];
	uint8_t _side;
}
@end

@implementation Luna

// MARK: - init
- (instancetype)init
{
	self = [super init];
	if (self) {
		[self initBoard];
	}
	return self;
}

- (void)initBoard {
	memcpy(_board, Luna_InitBoard, 256);
	memcpy(_chess, Luna_InitChess, 48);
	_state = LunaStateRedPlayer;
	_isThinking = NO;
}

// MARK: - Read-Only Properties
- (NSArray<NSNumber *> *)chesses {
	NSMutableArray<NSNumber *> *array = [NSMutableArray array];
	for (int i = 16; i < 48; i++) {
		[array addObject:@(_chess[i])];
	}
	return [NSArray arrayWithArray:array];
}

- (uint16_t)lastMove {
	return (170 << 8) + 84;
}

- (BOOL)isAnotherChoiceWith:(Luna_Location)location {
	NSAssert(Luna_LegalLocation[location] == 1, @"%s: location is not legal", __FUNCTION__);
	
	uint8_t chess = _board[location];
	if (chess && !Luna_IsNotSameSide(chess, _side)) {
		return YES;
	}
	return NO;
}

- (NSArray<NSNumber *> *)legalMovesWith:(Luna_Location)location {
	return @[ @55 ];
}

- (LunaMoveState)moveChessWith:(Luna_Move)move {
	return LunaMoveStateEatCheck;
}

@end
