//
//  LunaHistoryStack.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecordStack.h"
#import "NSString+Subscript.h"

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
	
	if (file == nil || file.isEmpty) {
		return;
	}
	
	NSArray<NSString *> *rows = [file componentsSeparatedByString:@"\n"];
	
	if (!rows.firstObject.isEmpty) {
		self.firstSide = rows.firstObject[0].unsignedShortValue - '0';
		self.firstCode = [rows.firstObject substringFromIndex:1];
	}
	
	for (int i = 1; i < rows.count; i++) {
		if (!rows[i].isEmpty) {
			LunaRecord *record = [LunaRecord recordWithString:rows[i]];
			[self push:record];
		}
	}
}

- (NSString *)historyFileWithCode:(BOOL)withCode {
	NSMutableString *file = [NSMutableString stringWithFormat:@"%d%@", self.firstSide, self.firstCode];
	
	for (LunaRecord *record in self.allRecords) {
		[file appendString:@"\n"];
		[file appendString: [record textWithCode:withCode]];
	}
	return [NSString stringWithString:file];
}

// MARK: - Stack Operation.
- (void)push:(LunaRecord *)record {
	[_records addObject:record];
}

- (LunaRecord *)pop {
	LunaRecord *last = _records.lastObject;
	[_records removeLastObject];
    return last;
}

- (LunaRecord *)peek {
    return _records.lastObject;
}

- (LunaRecord *)objectAtIndexedSubscript:(NSUInteger)idx {
	return _records[idx];
}

- (void)clear {
	_firstSide = NO;
	_firstCode = [self.delegate initialCode];
	[_records removeAllObjects];
}

- (NSArray<LunaRecord *> *)allRecords {
    return [NSArray arrayWithArray:_records];
}

- (NSUInteger)count {
	return _records.count;
}

- (NSString *)characters {
	NSMutableString *characters = [NSMutableString string];
	for (LunaRecord *record in _records) {
		[characters appendFormat:@"\n%@", record.character];
	}
	
	return characters;
}

@end
