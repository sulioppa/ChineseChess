//
//  Luna.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: - This enum reveals the state of game, it can be over or red player's turn or black player's turn.
typedef NS_ENUM(uint8_t, LunaState) {
	LunaStateRedPlayer,
	LunaStateBlackPlayer,
	LunaStateDraw,
	LunaStateRedPlayerWin,
	LunaStateBlackPlayerWin
};

typedef NS_ENUM(uint8_t, LunaMoveState) {
	LunaMoveStateSelect,
	LunaMoveStateNormal,
	LunaMoveStateEat,
	LunaMoveStateCheck,
	LunaMoveStateCheckMate,
	LunaMoveStateEatCheck,
	LunaMoveStateEatCheckMate
};

// MARK: - Typedef
typedef uint8_t Luna_Location;
typedef uint16_t Luna_Move;

@interface Luna : NSObject

// MARK: - Read-Only Properties
@property (nonnull, nonatomic, readonly) NSArray<NSNumber *> *chesses;

// the lastest move
@property (nonatomic, readonly) Luna_Move lastMove;

// the state reveals the state of game.
@property (nonatomic, readonly) LunaState state;

// see if user want to choose another chess.
- (BOOL)isAnotherChoiceWith:(Luna_Location)location;

// generate legal moves
- (nonnull NSArray<NSNumber *> *)legalMovesWith:(Luna_Location)location;

- (LunaMoveState)moveChessWith:(Luna_Move)move;

/* MARK: - AI
 * the isThinking reveals the AI is thinking or not, you can stop it by setting it 'NO'.*/
@property (nonatomic) BOOL isThinking;

@end
