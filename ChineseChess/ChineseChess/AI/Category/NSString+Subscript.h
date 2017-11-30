//
//  NSString+Subscript.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/29.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Subscript)

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface NSString (Empty)

- (BOOL)isEmpty;

@end

@interface NSMutableString (Unichar)

- (void)appendChar:(unichar)c;

@end
