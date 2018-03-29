//
//  LunaRecordRuler.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/29.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Luna.h"

@class LunaRecord;
@interface LunaRecordRuler : NSObject

+ (LunaBoardState)analyzeWithRecords:(NSArray<LunaRecord *> *)records currentSide:(const uint8_t)side chesses:(uint32_t)chesses;

@end
