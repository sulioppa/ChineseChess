//
//  LunaRecordCharacter.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/30.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecordCharacter.h"
#import "Luna+PreGenerate.h"
#import "NSString+Subscript.h"

@implementation LunaRecordCharacter

+ (NSString *)characterRecordWithMove:(const uint16_t)move board:(const uint8_t *const)board array:(const uint8_t *const)array {
	const uint8_t from = LCMoveGetLocationFrom(move), to = LCMoveGetLocationTo(move);
	const uint8_t chess = board[from];
	const BOOL isBlack = chess > 31;
	
	NSMutableString *character = [NSMutableString string];
	
	NSString *name = [self chessNameWithChess:chess];
	NSString *multi = [self multiChessDescription:from board:board array:array];
	
	if (multi.isEmpty) {
		NSString *column = [self columnStringWithNumber:LCLocationGetColumn(from) - 2 isBlack:isBlack];
		[character appendFormat:@"%@%@", name, column];
	} else {
		[character appendFormat:@"%@%@", multi, name];
	}

	if (LCLocationRowIsEqualToLocation(from, to)) {
		// 直行 平
		NSString *column = [self columnStringWithNumber:LCLocationGetColumn(to) - 2 isBlack:isBlack];
		[character appendFormat:@"平%@", column];
	} else if (LCLocationColumnIsEqualToLocation(from, to)) {
		// 直行 进退
		NSString *offset = [self offsetStringWithNumber:abs(from - to) >> 4 isBlack:isBlack];
		NSString *direction = [self directionWithFrom:from to:to isBlack:isBlack];
		[character appendFormat:@"%@%@", direction, offset];
	} else {
		// 其他 进退
		NSString *column = [self columnStringWithNumber:LCLocationGetColumn(to) - 2 isBlack:isBlack];
		NSString *direction = [self directionWithFrom:from to:to isBlack:isBlack];
		[character appendFormat:@"%@%@", direction, column];
	}
	
	return [NSString stringWithString:character];
}

+ (NSString *)chessNameWithChess:(const uint8_t)chess {
	NSString *names[48] = { 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,
		@"帥",
		@"仕", @"仕",
		@"相", @"相",
		@"馬", @"馬",
		@"車", @"車",
		@"炮", @"炮",
		@"兵", @"兵", @"兵", @"兵", @"兵",
		@"將",
		@"士", @"士",
		@"象", @"象",
		@"馬", @"馬",
		@"車", @"車",
		@"砲", @"砲",
		@"卒", @"卒", @"卒", @"卒", @"卒"
	};
	return names[chess];
}

+ (NSString *)multiChessDescription:(const uint8_t)from board:(const uint8_t *const)board array:(const uint8_t *const)array {
	const uint8_t chess = board[from];
	const BOOL isBlack = chess > 31;
	
	if ((chess & 15) == 0) {
		// K
		return @"";
	}
	
	if ((chess & 15) < 11) {
		// A, B, N, R, C
		const uint8_t another = (chess & 1) ? chess + 1 : chess - 1;
		
		if (array[another] && LCLocationColumnIsEqualToLocation(from, array[another])) {
			return (isBlack ^ (from < array[another])) ? @"前" : @"后";
		}
	} else {
		// P
		uint8_t count = 1, biggerCount = 0;
		
		for (uint8_t i = 27 + (isBlack << 4); i & 15; i++) {
			if (i != chess && array[i] && LCLocationColumnIsEqualToLocation(from, array[i])) {
				count++;
				if (from > array[i]) {
					biggerCount++;
				}
			}
		}
		
		switch (count) {
			case 2:
				return isBlack ^ biggerCount ? @"后" : @"前";
			case 3:
			case 4:
			case 5:
				return [self offsetStringWithNumber: isBlack ? count - biggerCount : biggerCount + 1 isBlack:isBlack];
			default:
				break;
		}
	}
	
	return @"";
}

+ (NSString *)offsetStringWithNumber:(uint8_t)number isBlack:(BOOL)isBlack {
	NSString *string[2][10] = {
		{ @"零", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九" },
		{ @" 0 ", @" 1 ", @" 2 ", @" 3 ", @" 4 ", @" 5 ", @" 6 ", @" 7 ", @" 8 ", @" 9 " }
	};
	return string[isBlack][number];
}

+ (NSString *)columnStringWithNumber:(uint8_t)number isBlack:(BOOL)isBlack {
	return [self offsetStringWithNumber:isBlack ? number : 10 - number isBlack:isBlack];
}

+ (NSString *)directionWithFrom:(uint8_t)from to:(uint8_t)to isBlack:(BOOL)isBlack {
	return  (isBlack ^ (from < to)) ? @"退" : @"进";
}

@end
