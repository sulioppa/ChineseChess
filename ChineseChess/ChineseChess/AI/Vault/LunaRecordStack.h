//
//  LunaRecordStack.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/27.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LunaCodingProtocol.h"
#import "LunaRecord.h"

@interface LunaRecordStack : NSObject

- (instancetype)initWithCoder:(id<LunaCoding>)coder;

@property (nonatomic) BOOL firstSide;

@property (nonatomic) NSString *firstCode;

- (void)reloadWith:(NSString *)file;

- (NSString *)historyFileWithCode:(BOOL)withCode;

// MARK: - History Operation
@property (nonatomic) NSInteger currentIndex;

- (NSString *)historyFileWithCode:(BOOL)withCode at:(NSInteger)idx;

- (LunaRecord *)currentRecord;

- (LunaRecord *)moveForward;

- (LunaRecord *)backForward;

// MARK: - Stack Operation.
- (void)push:(LunaRecord *)record;

- (LunaRecord *)pop;

- (LunaRecord *)peek;

- (LunaRecord *)objectAtIndexedSubscript:(NSUInteger)idx;

- (void)clear;

- (NSArray<LunaRecord *> *)allRecords;

- (NSUInteger)count;

- (NSString *)characters;

@end
