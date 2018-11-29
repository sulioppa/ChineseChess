//
//  Luna+NextStep.h
//  Luna
//
//  Created by 李夙璃 on 2018/11/23.
//  Copyright © 2018 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LunaNextStep : NSObject

- (void)nextStepWithFEN:(NSString *)FEN
             targetSide:(BOOL)side
            searchDepth:(int)depth
            bannedMoves:(NSArray<NSNumber *> *)bannedMoves
             isThinking:(BOOL *)isThinking
                  block:(void (^)(float progress, UInt16 move))block;

@end

NS_ASSUME_NONNULL_END
