//
//  LunaRecordVault.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/11/30.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LunaRecordVault : NSObject

+ (UInt16)searchVaultWithFEN:(NSString *)FEN targetSide:(BOOL)side;

#if DEBUG
+ (void)expandVaultWithDirectory:(NSString *)directory;

+ (void)writeToFile:(NSString *)path;
#endif

@end
