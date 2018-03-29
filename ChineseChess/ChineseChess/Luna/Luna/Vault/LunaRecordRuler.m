//
//  LunaRecordRuler.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/29.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecordRuler.h"
#import "LunaRecord.h"

@implementation LunaRecordRuler

+ (LunaBoardState)analyzeWithRecords:(NSArray<LunaRecord *> *)records currentSide:(const uint8_t)side chesses:(uint32_t)chesses {
    if (records.count == 0) {
        return side;
    }
	
	// 判负，长将、长捉超过4次。
	const uint8_t steps = 9;
	if (records.lastObject.catch && records.count >= steps) {
		NSArray<LunaRecord *> *rounds = [records subarrayWithRange:NSMakeRange(records.count - steps, steps)];
		BOOL isLongCatch = YES;
		
		for (int index = 0, max = steps - 1; index < max; index += 2) {
			LunaRecord *last = rounds.lastObject;
			LunaRecord *step = rounds[index];
			
			if (last.chess == step.chess && last.catch == step.catch) {
				continue;
			} else {
				isLongCatch = NO;
				break;
			}
		}
		
		if (isLongCatch) {
			return side ? LunaBoardStateWinLongCatchBlack : LunaBoardStateWinLongCatchRed;
		}
	}
	
	// 和棋，双方无进攻棋子。
	if (!(chesses & 0xffe0ffe0)) {
		return LunaBoardStateDrawBothSideHaveNoneAttckChess;
	}
	
	// 和棋，重复局面出现超过5次。
	if (records.count > 10) {
		NSMutableArray<NSString *> *positions = [NSMutableArray arrayWithCapacity:records.count];
		
		for (LunaRecord *record in records) {
			[positions addObject:record.position];
		}
		
		for (int index = (int)(positions.count - 1); index >= 10; index --) {
			NSInteger count = 0;
			
			for (NSString *position in positions) {
				if ([positions[index] isEqualToString:position]) {
					count++;
				}
			}
			
			if (count > 5) {
				return LunaBoardStateDrawSamePositionMultiTimes;
			}
		}
	}
	
	// 和棋，50回合不吃子。
	if (records.count > 100) {
		uint8_t count = 0;
		
		for (int index = (int)(records.count - 1); index >= 0; index--, count++) {
			if (records[index].eat) {
				break;
			}
		}
		
		if (count > 100) {
			return LunaBoardStateDraw50RoundHaveNoneEat;
		}
	}
	
	return side;
}

@end
