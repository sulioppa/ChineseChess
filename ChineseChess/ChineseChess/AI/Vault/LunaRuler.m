//
//  LunaRuler.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/29.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRuler.h"
#import "LunaRecord.h"

@implementation LunaRuler

+ (LunaBoardState)analyze:(NSArray<LunaRecord *> *)records {
	return (records.count & 1) ? LunaBoardStateTurnBlackSide : LunaBoardStateTurnRedSide;
}

+ (NSString *)characterRecordWithMove:(uint16_t)move board:(const uint8_t *const)board {
	return @"";
}

@end
