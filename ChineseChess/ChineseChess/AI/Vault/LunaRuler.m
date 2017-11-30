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

+ (LunaBoardState)analyzeWithRecords:(NSArray<LunaRecord *> *)records currentSide:(const uint8_t)side  {
    if (records.count == 0) {
        return side;
    }
    
	return side;
}

+ (NSString *)characterRecordWithMove:(uint16_t)move board:(const uint8_t *const)board {
	return @"";
}

@end
