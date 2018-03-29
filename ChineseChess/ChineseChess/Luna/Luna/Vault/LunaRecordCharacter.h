//
//  LunaRecordCharacter.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/30.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LunaRecordCharacter : NSObject

+ (NSString *)characterRecordWithMove:(const uint16_t)move board:(const uint8_t *const)board array:(const uint8_t *const)array;

@end
