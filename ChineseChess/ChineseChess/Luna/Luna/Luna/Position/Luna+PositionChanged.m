//
//  Luna+PositionChanged.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+PositionChanged.h"
#import "Luna+PositionLegal.h"

void LCPositionChanged(LCMutablePositionRef position, LCMutableEvaluateRef evaluate, LCMoveRef move, UInt16 *const buffer) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)move + 1);
    to = *((LCLocation *)move);
    
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
    *buffer = LCChessGetZobristOffset(chess, from);

    position->hash ^= LCZobristConstHash[*buffer];
    position->key ^= LCZobristConstKey[*buffer];
    
    *buffer = LCChessGetZobristOffset(chess, to);

    position->hash ^= LCZobristConstHash[*buffer];
    position->key ^= LCZobristConstKey[*buffer];
    
    if (eat) {
        position->chess[eat] = 0;

        *buffer = LCChessGetZobristOffset(eat, to);
        
        position->hash ^= LCZobristConstHash[*buffer];
        position->key ^= LCZobristConstKey[*buffer];

        LCBitChessRemoveChess(&(position->bitchess), eat);
        evaluate->material -= *(evaluate->dynamicChessValue[eat] + to);
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnAdd(position->row + row, column);
        LCRowColumnAdd(position->column + column, row);
    }
    
    *buffer = eat;
}

void LCPositionRecover(LCMutablePositionRef position, LCMutableEvaluateRef evaluate, LCMoveRef move, UInt16 *const buffer) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)move + 1);
    to = *((LCLocation *)move);
    
    chess = position->board[to];
    eat = *buffer;
    
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
    *buffer = LCChessGetZobristOffset(chess, to);

    position->hash ^= LCZobristConstHash[*buffer];
    position->key ^= LCZobristConstKey[*buffer];
    
    *buffer = LCChessGetZobristOffset(chess, from);

    position->hash ^= LCZobristConstHash[*buffer];
    position->key ^= LCZobristConstKey[*buffer];
    
    if (eat) {
        position->chess[eat] = to;
        
        *buffer = LCChessGetZobristOffset(eat, to);
        
        position->hash ^= LCZobristConstHash[*buffer];
        position->key ^= LCZobristConstKey[*buffer];

        LCBitChessAddChess(&(position->bitchess), eat);
        evaluate->material += *(evaluate->dynamicChessValue[eat] + to);
    } else {
        row = LCLocationGetRow(to);
        column = LCLocationGetColumn(to);
        
        LCRowColumnRemove(position->row + row, column);
        LCRowColumnRemove(position->column + column, row);
    }
}

Bool LCPositionIsLegalIfChangedByMove(LCMutablePositionRef position, LCMoveRef move, UInt16 *const buffer) {
#if LC_SingleThread
    static LCLocation from, to;
    static LCChess chess, eat;
    static LCRow row, column;
#else
    LCLocation from, to;
    LCChess chess, eat;
    LCRow row, column;
#endif
    
    from = *((LCLocation *)move + 1);
    to = *((LCLocation *)move);
    
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
    
    *buffer = LCPositionIsLegal(position);

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

    return *buffer;
}
