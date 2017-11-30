//
//  NSString+Subscript.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/29.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "NSString+Subscript.h"

@implementation NSString (Subscript)

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx {
	return @([self characterAtIndex:idx]);
}

@end

@implementation NSString (Empty)

- (BOOL)isEmpty {
	return self.length == 0;
}

@end

@implementation NSMutableString (Unichar)

- (void)appendChar:(unichar)c {
	[self appendFormat:@"%C", c];
}

@end
