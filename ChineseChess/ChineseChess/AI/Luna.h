//
//  Luna.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Luna : NSObject

// chess array
@property (nonnull, nonatomic, readonly) NSArray<NSNumber *> *chesses;
// the lastest move
@property (nonatomic, readonly) uint16_t lastMove;

@end
