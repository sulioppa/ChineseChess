//
//  LunaRecord.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecord.h"

static inline NSString * MoveToString(const uint16_t move) {
	return [NSString stringWithFormat:@"%04x", move].uppercaseString;
}

static inline uint16_t HexValueOfUnichar(const unichar c) {
	return '0' <= c && c <= '9' ? c - '0' : c - 'A' + 10;
}

uint16_t StringToMove(NSString *string) {
	uint16_t move = 0;
	for (int i = (int)(string.length - 1), offset = 0; i >= 0; i--, offset += 4) {
		move += HexValueOfUnichar([string characterAtIndex:i]) << offset;
	}
	return move;
}

@implementation LunaRecord

+ (LunaRecord *)recordWithString:(NSString *)string {
	LunaRecord *record = [LunaRecord new];
	
	if (string.length > 4) {
		NSRange range = [string rangeOfString:@" "];
		record.code = [string substringToIndex:range.location];
		string = [string substringFromIndex:range.location + range.length];
	}
	
	record.move = StringToMove(string);
	return record;
}

- (NSString *)textWithCode:(BOOL)withCode {
	if (withCode) {
		return [NSString stringWithFormat:@"%@ %@", self.code, MoveToString(self.move)];
	}
	
	return MoveToString(self.move);
}

- (void)setCharacter:(NSString *)character count:(NSUInteger)count {
	if (count & 1) {
		_character = [NSString stringWithFormat:@"%4c %@", ' ',character];
	} else {
		count = (count >> 1) + 1;
		_character = [NSString stringWithFormat:@"%3lu. %@", (unsigned long)count, character];
	}
}

@end
