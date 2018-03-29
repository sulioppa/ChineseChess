//
//  LunaFENCoder.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaFENCoder.h"
#import "NSString+Subscript.h"

@implementation LunaFENCoder

// MARK: - LunaCoding
- (void)decode:(NSString *)code board:(uint8_t *const)board {
	memset(board, 0, 256);
	NSDictionary<NSNumber *, NSNumber *> *map = @{
						  @('K'): @(16),
						  @('A'): @(17),
						  @('B'): @(19),
						  @('N'): @(21),
						  @('R'): @(23),
						  @('C'): @(25),
						  @('P'): @(27),
						  @('k'): @(32),
						  @('a'): @(33),
						  @('b'): @(35),
						  @('n'): @(37),
						  @('r'): @(39),
						  @('c'): @(41),
						  @('p'): @(43),
						  };
	
	uint8_t chess[48] = { 0 };
	
	for (int i = 0, index = (3 << 4) + 3; i < code.length; i++) {
		if (map[code[i]] != nil ) {
			board[index] = [self chess:chess start:map[code[i]].unsignedCharValue];
			index++;
		} else {
			if (code[i].unsignedShortValue == '/') {
				index += 7;
			} else {
				for (int count = '0'; count < code[i].unsignedShortValue; count++, index++) {
					board[index] = 0;
				}
			}
		}
	}
}

- (NSString *)encode:(const uint8_t *const)board {
	NSMutableString *FEN = [NSMutableString stringWithCapacity:64];
	const unichar split = '/';
	const unichar chess[48] = { 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,
		'K',
		'A', 'A',
		'B', 'B',
		'N', 'N',
		'R', 'R',
		'C', 'C',
		'P', 'P', 'P', 'P', 'P',
		'k',
		'a', 'a',
		'b', 'b',
		'n', 'n',
		'r', 'r',
		'c', 'c',
		'p', 'p', 'p', 'p', 'p'
	};
	
	for (int row = 3; row < 13; row++) {
		int index = (row << 4) + 3, max = index + 9, space = 0;
		
		while(true) {
			if (chess[board[index]] != 0) {
				if(space != 0) {
					[FEN appendChar:space + '0'];
					space = 0;
				}
				
				[FEN appendChar:chess[board[index]]];
			} else {
				space++;
			}
			
			index++;
			if (index == max) {
				if(space != 0) {
					[FEN appendChar:space + '0'];
				}
				
				[FEN appendChar:split];
				break;
			}
		}
	}
	
    return [NSString stringWithString:FEN];
}

- (NSString *)initialCode {
	return @"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR/";
}

// MARK: - Private
- (uint8_t)chess:(uint8_t *const)array start:(uint8_t)start {
	if ((start & 15) == 0) {
		// K
		array[start] = 1;
		return start;
	}
	
	if ((start & 15) > 10) {
		// P
		for (int max = start + 5; start < max; start++) {
			if (array[start] == 0) {
				array[start] = 1;
				return start;
			}
		}
		NSAssert((start & 15) != 0, @"FEN格式错误");
	}
	
	// A, B, N, R, C
	start = array[start] == 0 ? start : start + 1;
	array[start] = 1;
	return start;
}

@end
