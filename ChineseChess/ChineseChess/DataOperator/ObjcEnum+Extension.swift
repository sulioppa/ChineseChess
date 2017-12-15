//
//  ObjcEnum+Extension.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/15.
//  Copyright © 2017年 StarLab. All rights reserved.
//

// MARK: - LunaBoardState
extension LunaBoardState {
	
	public var description: String {
		switch self {
		case .turnRedSide:
			return " 红方走 "
		case .turnBlackSide:
			return " 黑方走 "
			
		case .draw50RoundHaveNoneEat:
			return " 和棋, 50回合不吃子 "
		case .drawSamePositionMultiTimes:
			return " 和棋, 相同的局面出现多次 "
		case .drawBothSideHaveNoneAttckChess:
			return " 和棋, 双方无可进攻的棋子 "
			
		case .winNormalRed:
			return " 红胜 "
		case .winNormalBlack:
			return " 黑胜 "
		case .winLongCatchRed:
			return " 红胜, 黑方长捉(长将) "
		case .winLongCatchBlack:
			return " 黑胜, 红方长捉(长将) "
		}
	}
	
}
