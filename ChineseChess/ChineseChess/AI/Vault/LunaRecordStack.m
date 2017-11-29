//
//  LunaHistoryStack.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecordStack.h"

@interface LunaRecordStack()
@property (nonatomic) id<LunaCoding> delegate;
@property (nonatomic) NSMutableArray<LunaRecord *> *records;
@end

@implementation LunaRecordStack

- (instancetype)initWithCoder:(id<LunaCoding>)coder {
    if (self = [super init]) {
		self.delegate = coder;
		_records = [NSMutableArray array];
		[self clear];
    }
    return self;
}

- (void)reloadWith:(NSString *)file {
    [self clear];
	
	if (file == nil) {
		return;
	}
}

- (NSString *)historyFileWithCode:(BOOL)withCode {
    return @"";
}

// MARK: - Stack Operation.
- (void)push:(LunaRecord *)history {
	[_records addObject:history];
}

- (LunaRecord *)pop {
	LunaRecord *last = _records.lastObject;
	[_records removeLastObject];
    return last;
}

- (LunaRecord *)peek {
    return _records.lastObject;
}

- (void)clear {
	_firstSide = 0;
	_firstCode = [self.delegate initialCode];
	[_records removeAllObjects];
}

- (NSArray<LunaRecord *> *)allRecords {
    return [NSArray arrayWithArray:_records];
}

- (NSUInteger)count {
	return _records.count;
}

@end
