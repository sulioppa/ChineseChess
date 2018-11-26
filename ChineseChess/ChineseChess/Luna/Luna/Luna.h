//
//  Luna.h
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/22.
//  Copyright © 2017年 StarLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LunaRecord.h"

// MARK: - LunaBoardState, this enum reveals the state of game, it can be over or red player's turn or black player's turn.
typedef NS_ENUM(uint8_t, LunaBoardState) {
	LunaBoardStateTurnRedSide = 0,
	LunaBoardStateTurnBlackSide = 1 << 0,
	LunaBoardStateDrawSamePositionMultiTimes = 1 << 1,
	LunaBoardStateDraw50RoundHaveNoneEat = 1 << 2,
	LunaBoardStateDrawBothSideHaveNoneAttckChess = 1 << 3,
	LunaBoardStateWinNormalRed = 1 << 4,
	LunaBoardStateWinNormalBlack = 1 << 5,
	LunaBoardStateWinLongCatchRed = 1 << 6,
	LunaBoardStateWinLongCatchBlack = 1 << 7
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

// MARK: - Typedef
typedef uint8_t LunaLocation;

typedef uint8_t LunaChess;

typedef uint16_t LunaMove;

// MARK: - AI Luna.
@interface Luna : NSObject

// chess array
@property (nonnull, nonatomic, readonly) NSArray<NSNumber *> *chesses;

// the state reveals the state of game.
@property (nonatomic, readonly) LunaBoardState state;

@property (nonatomic, readonly) BOOL side;

// AI Control, the isThinking reveals the AI is thinking or not, you can stop it by setting it 'NO'.
@property (nonatomic, readwrite) BOOL isThinking;

- (void)nextStepWithDepth:(int)depth block:(void (^ _Nonnull)(float progress, LunaMove move))block;

@end

// MARK: - AI Luna. (Game)
@interface Luna (Game)

// last reocrd.
@property (nullable, nonatomic, readonly) LunaRecord *lastMove;

// see if user want to choose another chess.
- (BOOL)isAnotherChoiceWithLocation:(LunaLocation)location;

// generate legal moves.
- (nonnull NSArray<NSNumber *> *)legalMovesWithLocation:(LunaLocation)location;

// do a chess move, return a state indicates how this move affect the game.
- (LunaMoveState)moveChessWithMove:(LunaMove)move;

// undo a chess move from move stack, move = 0 indicates there's no more move in stack.
- (LunaChess)regretWithMove:(nonnull LunaMove *)move;

@end

// MARK: - AI Luna. (History)
@interface Luna (History)

// all records
@property (nonnull, nonatomic, readonly) NSArray<LunaRecord *> *records;

// count of records
@property (nonatomic, readonly) NSUInteger count;

// character history
@property (nonnull, nonatomic, readonly) NSString *characters;

// reset board with file record.
- (void)initBoardWithFile:(nullable NSString *)file;

// return the file record of game.
- (nonnull NSString *)historyFile;

- (nonnull NSString *)historyFileAt:(NSInteger)idx;

// move the index at index
- (void)moveIndexAt:(NSInteger)idx;

// current record
@property (nullable, nonatomic, readonly) LunaRecord *currentRecord;

// move Forward
- (nullable LunaRecord *)moveForward;

// back Forward
- (nullable LunaRecord *)backForward;

@end

// MARK: - LunaChessState
typedef NS_ENUM(NSUInteger, LunaPutChessState) {
	LunaPutChessStateNormalPut,
	LunaPutChessStateNormalEat,
	LunaPutChessStateWrongPut,
	LunaPutChessStateWrongEat,
};

// MARK: - LunaDoneState
typedef NS_ENUM(NSUInteger, LunaEditDoneState) {
	LunaEditDoneStateNormal,
	LunaEditDoneStateWrongFaceToFace,
	LunaEditDoneStateWrongIsCheckedMate,
	LunaEditDoneStateWrongCheck
};

// MARK: - AI Luna. (Edit)
@interface Luna (Edit)

// the chesses can put.
@property (nonnull, nonatomic, readonly) NSArray<NSNumber *> *putChesses;

// the chess at the location.
- (LunaChess)chessAtLocation:(LunaLocation)location;

// put, move, erase a chess.
- (LunaPutChessState)putWithChess:(LunaChess)chess at:(LunaLocation)location;

- (LunaPutChessState)moveWithMove:(LunaMove)move;

- (LunaPutChessState)eraseWithLocation:(LunaLocation)location;

// check the board with the expected side.
- (LunaEditDoneState)isEditDone:(LunaBoardState)state;

// init the board.
- (void)resetBoard;

// make the board only left the kings.
- (void)clearBoard;

@end
