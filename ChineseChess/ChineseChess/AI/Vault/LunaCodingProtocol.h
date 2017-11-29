//
//  LunaCodingProtocol.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LunaCoding

@required
- (NSString *)encode:(const uint8_t *const)board;

- (void)decode:(NSString *)code board:(uint8_t *const)board;

- (NSString *)initialCode;

@end

