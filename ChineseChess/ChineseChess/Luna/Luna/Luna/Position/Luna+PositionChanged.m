//
//  Luna+PositionChanged.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PositionChanged.h"
#import "Luna+PositionLegal.h"

void LCPositionChanged(LCMutablePositionRef position, LCMoveTrack *const track) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)track + 3);
    to = *((LCLocation *)track + 2);
    
    chess = position->board[from];
    eat = position->board[to];

    // board, chess
    position->board[from] = 0;
    position->board[to] = chess;
    
    position->chess[chess] = to;
    
    // row, column
    row = LCLocationGetRow(from);
    column = LCLocationGetColumn(from);
    
    LCRowColumnRemove(position->row + row, column);
    LCRowColumnRemove(position->column + column, row);
    
    // hash, key
    LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(chess, from));
    
    position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
    position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];
    
    LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(chess, to));
    
    position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
    position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];
    
    if (eat) {
        position->chess[eat] = 0;

        LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(eat, to));
        
        position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
        position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];
        
        LCBitChessRemoveChess(&(position->bitchess), eat);
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnAdd(position->row + row, column);
        LCRowColumnAdd(position->column + column, row);
    }
    
    LCMoveTrackSetBuffer(track, eat);
}

void LCPositionRecover(LCMutablePositionRef position, LCMoveTrack *const track) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)track + 3);
    to = *((LCLocation *)track + 2);
    
    chess = position->board[to];
    eat = LCMoveTrackGetBuffer(track);
    
    // board, chess
    position->board[from] = chess;
    position->board[to] = eat;
    
    position->chess[chess] = from;

    // row, column
    row = LCLocationGetRow(from);
    column = LCLocationGetColumn(from);
    
    LCRowColumnAdd(position->row + row, column);
    LCRowColumnAdd(position->column + column, row);
    
    // hash, key
    LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(chess, to));
    
    position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
    position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];
    
    LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(chess, from));
    
    position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
    position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];
    
    if (eat) {
        position->chess[eat] = to;
        
        LCMoveTrackSetBuffer(track, LCChessGetZobristOffset(eat, to));
        
        position->hash ^= LCZobristConstHash[LCMoveTrackGetBuffer(track)];
        position->key ^= LCZobristConstKey[LCMoveTrackGetBuffer(track)];

        LCBitChessAddChess(&(position->bitchess), eat);
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnRemove(position->row + row, column);
        LCRowColumnRemove(position->column + column, row);
    }
}

Bool LCPositionIsLegalIfChangedByTrack(LCMutablePositionRef position, LCMoveTrack *const track) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)track + 3);
    to = *((LCLocation *)track + 2);
    
    chess = position->board[from];
    eat = position->board[to];
    
    // board, chess
    position->board[from] = 0;
    position->board[to] = chess;
    
    position->chess[chess] = to;

    // row, column
    row = LCLocationGetRow(from);
    column = LCLocationGetColumn(from);
    
    LCRowColumnRemove(position->row + row, column);
    LCRowColumnRemove(position->column + column, row);
    
    if (eat) {
        position->chess[eat] = 0;
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnAdd(position->row + row, column);
        LCRowColumnAdd(position->column + column, row);
    }
    
    LCMoveTrackSetBuffer(track, LCPositionIsLegal(position));
   
    // board, chess
    position->board[from] = chess;
    position->board[to] = eat;
    
    position->chess[chess] = from;
    
    // row, column
    row = LCLocationGetRow(from);
    column = LCLocationGetColumn(from);
    
    LCRowColumnAdd(position->row + row, column);
    LCRowColumnAdd(position->column + column, row);
    
    if (eat) {
        position->chess[eat] = to;
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnRemove(position->row + row, column);
        LCRowColumnRemove(position->column + column, row);
    }

    return LCMoveTrackGetBuffer(track);
}
