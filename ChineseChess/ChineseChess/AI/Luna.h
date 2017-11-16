//
//  Luna.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: - LunaBoardState, this enum reveals the state of game, it can be over or red player's turn or black player's turn.
typedef NS_ENUM(uint8_t, LunaBoardState) {
	LunaBoardStateRedPlayer,
	LunaBoardStateBlackPlayer,
	LunaBoardStateDraw,
	LunaBoardStateRedPlayerWin,
	LunaBoardStateBlackPlayerWin
};

// MARK: - LunaMoveState, this enum reveals the state of a move, it can be check or mate...
typedef NS_ENUM(uint8_t, LunaMoveState) {
	LunaMoveStateSelect,
	LunaMoveStateNormal,
	LunaMoveStateEat,
	LunaMoveStateCheck,
	LunaMoveStateCheckMate,
	LunaMoveStateEatCheck,
	LunaMoveStateEatCheckMate
};

typedef uint8_t Luna_Location;

typedef uint8_t Luna_Chess;

typedef uint8_t Luna_Side;

typedef uint16_t Luna_Move;

// MARK: - AI Luna.
@interface Luna : NSObject

// chess array
- (nonnull NSArray<NSNumber *> *)chesses;

// the lastest move, return the move stack' top.
- (Luna_Move)lastMove;

// the state reveals the state of game.
@property (nonatomic, readonly) LunaBoardState state;

// AI Control, the isThinking reveals the AI is thinking or not, you can stop it by setting it 'NO'.
@property (nonatomic) BOOL isThinking;

@end

// MARK: - AI Luna. (Game)
@interface Luna (Game)

// reset board with FEN reocrd.
- (void)initBoardWithFEN:(nullable NSString *)FEN;

// see if user want to choose another chess.
- (BOOL)isAnotherChoiceWithLocation:(Luna_Location)location;

// generate legal moves.
- (nonnull NSArray<NSNumber *> *)legalMovesWithLocation:(Luna_Location)location;

// do a chess move, return a state indicates how this move affect the game.
- (LunaMoveState)moveChessWithMove:(Luna_Move)move;

@end
