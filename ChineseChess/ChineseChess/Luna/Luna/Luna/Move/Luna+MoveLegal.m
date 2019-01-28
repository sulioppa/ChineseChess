//
//  Luna+MoveLegal.m
//  Luna
//
//  Created by 李夙璃 on 2018/9/17.
//  Copyright © 2018年 李夙璃. All rights reserved.
//

#import "Luna+MoveLegal.h"

// MARK: - 任意着法 合理检测函数簇
Bool _LCMoveIsLegal_K(LCPositionRef position, LCMoveRef move) {
    return LCMoveMapConstRef->K[*move];
}

Bool _LCMoveIsLegal_A(LCPositionRef position, LCMoveRef move) {
    return LCMoveMapConstRef->A[*move];
}

Bool _LCMoveIsLegal_B(LCPositionRef position, LCMoveRef move) {
    return LCMoveMapConstRef->B[*move] && !position->board[LCMoveMapConstRef->B[*move]];
}

Bool _LCMoveIsLegal_N(LCPositionRef position, LCMoveRef move) {
    return LCMoveMapConstRef->N[*move] && !position->board[LCMoveMapConstRef->N[*move]];
}

Bool _LCMoveIsLegal_R(LCPositionRef position, LCMoveRef move) {
#if LC_SingleThread
    static LCLocation from, to;
#else
    LCLocation from, to;
#endif
    
    from = LCMoveGetLocationFrom(*move);
    to = LCMoveGetLocationTo(*move);
    
    if (LCLocationRowIsEqualToLocation(from, to)) {
        return LCMoveMapGetRowMapState(position->row[LCLocationGetRow(from)], LCLocationGetColumn(from), LCLocationGetColumn(to)) | LCMoveMapConstRef->MaskR;
    } else if (LCLocationColumnIsEqualToLocation(from, to)) {
        return LCMoveMapGetColumnMapState(position->column[LCLocationGetColumn(from)], LCLocationGetRow(from), LCLocationGetRow(to)) | LCMoveMapConstRef->MaskR;
    } else {
        return false;
    }
}

Bool _LCMoveIsLegal_C(LCPositionRef position, LCMoveRef move) {
#if LC_SingleThread
    static LCLocation from, to;
#else
    LCLocation from, to;
#endif
    
    from = LCMoveGetLocationFrom(*move);
    to = LCMoveGetLocationTo(*move);
    
    if (LCLocationRowIsEqualToLocation(from, to)) {
        return LCMoveMapGetRowMapState(position->row[LCLocationGetRow(from)], LCLocationGetColumn(from), LCLocationGetColumn(to)) | LCMoveMapConstRef->MaskC;
    } else if (LCLocationColumnIsEqualToLocation(from, to)) {
        return LCMoveMapGetColumnMapState(position->column[LCLocationGetColumn(from)], LCLocationGetRow(from), LCLocationGetRow(to)) | LCMoveMapConstRef->MaskC;
    } else {
        return false;
    }
}

Bool _LCMoveIsLegal_P(LCPositionRef position, LCMoveRef move) {
    return LCMoveMapConstRef->P[(position->side << 16) + *move];
}

Bool (*const _LCMoveIsLegal[16])(LCPositionRef, LCMoveRef) = {
    _LCMoveIsLegal_K,
    _LCMoveIsLegal_A, _LCMoveIsLegal_A,
    _LCMoveIsLegal_B, _LCMoveIsLegal_B,
    _LCMoveIsLegal_N, _LCMoveIsLegal_N,
    _LCMoveIsLegal_R, _LCMoveIsLegal_R,
    _LCMoveIsLegal_C, _LCMoveIsLegal_C,
    _LCMoveIsLegal_P, _LCMoveIsLegal_P, _LCMoveIsLegal_P, _LCMoveIsLegal_P, _LCMoveIsLegal_P
};

// MARK: - LCChessSideMap
const UInt8 _LCChessSideMap[LCChessLength] = {
    LCSideNan, LCSideNan, LCSideNan, LCSideNan,
    LCSideNan, LCSideNan, LCSideNan, LCSideNan,
    LCSideNan, LCSideNan, LCSideNan, LCSideNan,
    LCSideNan, LCSideNan, LCSideNan, LCSideNan,
    
    LCSideRed, LCSideRed, LCSideRed, LCSideRed,
    LCSideRed, LCSideRed, LCSideRed, LCSideRed,
    LCSideRed, LCSideRed, LCSideRed, LCSideRed,
    LCSideRed, LCSideRed, LCSideRed, LCSideRed,
    
    LCSideBlack, LCSideBlack, LCSideBlack, LCSideBlack,
    LCSideBlack, LCSideBlack, LCSideBlack, LCSideBlack,
    LCSideBlack, LCSideBlack, LCSideBlack, LCSideBlack,
    LCSideBlack, LCSideBlack, LCSideBlack, LCSideBlack
};

// MARK: - 任意着法 合理检测（用于杀手着法）
Bool LCPositionAnyMoveIsLegal(LCPositionRef position, LCMoveRef move) {
#if LC_SingleThread
    static LCChess chess;
#else
    LCChess chess;
#endif
    
    chess = position->board[LCMoveGetLocationFrom(*move)];
    
    if (_LCChessSideMap[chess] == position->side &&
        _LCChessSideMap[position->board[LCMoveGetLocationTo(*move)]] != position->side) {
        return _LCMoveIsLegal[chess & 0xf](position, move);
    }
    
    return false;
}
