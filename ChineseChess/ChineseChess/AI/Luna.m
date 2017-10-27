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
}
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

- (void)initBoard {
	memcpy(_board, LCBoard, 256);
	memcpy(_chess, LCChess, 48);
}

// MARK: - Properties
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

@end
