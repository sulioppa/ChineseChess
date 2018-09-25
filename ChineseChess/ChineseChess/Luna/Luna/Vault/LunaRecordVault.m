//
//  LunaRecordVault.m
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/30.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import "LunaRecordVault.h"
#import "NSString+Subscript.h"

// MARK: - Move
@interface LunaMove: NSObject
@property (nonatomic, readonly) UInt16 value;

- (instancetype)initWithValue:(UInt16)value;
- (instancetype)initWithString:(NSString *)string;
@end

@implementation LunaMove

static inline UInt16 HexValueOfUnichar(const unichar c) {
    return '0' <= c && c <= '9' ? c - '0' : c - 'A' + 10;
}

- (UInt16)StringToMove:(NSString *)string {
    UInt16 move = 0;
    
    for (int i = (int)(string.length - 1), offset = 0; i >= 0; i--, offset += 4) {
        move += HexValueOfUnichar([string characterAtIndex:i]) << offset;
    }
    
    return move;
}

- (instancetype)initWithValue:(UInt16)value {
    if (self = [super init]) {
        _value = value;
    }
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        _value = [self StringToMove:string];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%04x", _value].uppercaseString;
}

- (NSUInteger)hash {
    return _value;
}

- (BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[LunaMove class]]) {
        return self.value == ((LunaMove *)object).value;
    }
    
    return NO;
}

@end

// MARK: - Data
@interface LunaRecordVaultData: NSObject {
    NSMutableSet<LunaMove *> *_red;
    NSMutableSet<LunaMove *> *_black;
}

- (instancetype)initWithRed:(NSString *)red black:(NSString *)black;
- (void)expandWithMove:(LunaMove *)move targetSide:(BOOL)side;

- (LunaMove *)searchMoveWithSide:(BOOL)side;
@end

@implementation LunaRecordVaultData

- (instancetype)init
{
    if (self = [super init]) {
        _red = [NSMutableSet set];
        _black = [NSMutableSet set];
    }
    
    return self;
}

- (instancetype)initWithRed:(NSString *)red black:(NSString *)black {
    if (self = [super init]) {
        _red = [NSMutableSet set];
        _black = [NSMutableSet set];
        
        NSUInteger stringFrom, stringLength;
        
        for (stringFrom = 0, stringLength = red.length; (stringFrom + 3) < stringLength; stringFrom += 4) {
            [_red addObject: [[LunaMove alloc] initWithString:[red substringWithRange:NSMakeRange(stringFrom, 4)]]];
        }
        
        for (stringFrom = 0, stringLength = black.length; (stringFrom + 3) < stringLength; stringFrom += 4) {
            [_black addObject: [[LunaMove alloc] initWithString:[black substringWithRange:NSMakeRange(stringFrom, 4)]]];
        }
    }
    
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    
    [description appendString:@"@"];
    for (LunaMove *move in _red) {
        [description appendString:[move description]];
    }
    
    [description appendString:@"@"];
    for (LunaMove *move in _black) {
        [description appendString:[move description]];
    }
    
    return description;
}

- (LunaMove *)searchMoveWithSide:(BOOL)side {
    return [[self collection:side] anyObject];
}

- (void)expandWithMove:(LunaMove *)move targetSide:(BOOL)side {
    if (move) {
        [[self collection:side] addObject:move];
    }
}

- (NSMutableSet<LunaMove *> *)collection:(BOOL)side {
    return side ? _black : _red;
}

@end

// MARK: - Vault
@interface LunaRecordVault() {
    NSMutableDictionary<NSString *, LunaRecordVaultData *> *_vault;
}
@end

@implementation LunaRecordVault

+ (LunaRecordVault *)vault {
    static LunaRecordVault *vault = nil;
    
    if (vault == nil) {
        vault = [[LunaRecordVault alloc] init];
    }
    
    return vault;
}

- (instancetype)init
{
    if (self = [super init]) {
        _vault = [NSMutableDictionary dictionaryWithCapacity:4096];
        
        [self loadVault];
    }
    
    return self;
}

- (void)loadVault {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Vault" ofType:@"txt"];
    NSString *vault = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    if (vault == nil) {
        return;
    }
    
    NSArray<NSString *> *lines = [vault componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        if (line.length == 0) {
            continue;
        }
        
        NSArray<NSString *> *parts = [line componentsSeparatedByString:@"@"];
        _vault[parts[0]] = [[LunaRecordVaultData alloc] initWithRed:parts[1] black:parts[2]];
    }
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    
    [_vault enumerateKeysAndObjectsUsingBlock:^(NSString *FEN, LunaRecordVaultData *data, BOOL *stop) {
        [description appendFormat:@"%@%@\n", FEN, [data description]];
    }];
    
    return description;
}

// MARK: - 4种命中。
+ (UInt16)searchVaultWithFEN:(NSString *)FEN targetSide:(BOOL)side {
    return 0;
}

#if DEBUG
// MARK: - 扩展棋谱库
+ (void)expandVaultWithDirectory:(NSString *)directory {
    NSArray<NSString *> *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *fileName in filePaths) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", directory, fileName];
        NSString *file = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray<NSString *> *rows = [file componentsSeparatedByString:@"\n"];
        __block BOOL side = rows.firstObject[0].unsignedShortValue - '0';
        
        [rows enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
            if (idx == 0) return;
            
            if (string.length > 4) {
                NSRange range = [string rangeOfString:@" "];
                
                NSString *FEN = [string substringToIndex:range.location];
                LunaMove *move = [[LunaMove alloc] initWithString:[string substringFromIndex:range.location + range.length]];
                
                LunaRecordVaultData *data = [LunaRecordVault vault]->_vault[FEN];
                
                if (data == nil) {
                    data = [[LunaRecordVaultData alloc] init];
                    [LunaRecordVault vault]->_vault[FEN] = data;
                }
                
                [data expandWithMove:move targetSide:side];
                side = !side;
            }
        }];
    }
}

+ (void)writeToFile:(NSString *)path {
    [[[LunaRecordVault vault] description] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
#endif

@end


