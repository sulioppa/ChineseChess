//
//  Objc+Extension.swift
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
	
	public var isNormalState: Bool {
		return self.rawValue <= LunaBoardState.turnBlackSide.rawValue
	}
	
	public var result: String {
		switch self {
		case .turnRedSide, .turnBlackSide:
			return "结果: 未知"
			
		case .draw50RoundHaveNoneEat, .drawSamePositionMultiTimes, .drawBothSideHaveNoneAttckChess:
			return "结果: 和棋"
			
		case .winNormalRed, .winLongCatchRed:
			return "结果: 红胜 "
		case .winNormalBlack, .winLongCatchBlack:
			return "结果: 黑胜 "
		}
	}
	
	public var vs: String {
		switch self {
		case .turnRedSide, .turnBlackSide:
			return "-"
			
		case .draw50RoundHaveNoneEat, .drawSamePositionMultiTimes, .drawBothSideHaveNoneAttckChess:
			return "先和"
			
		case .winNormalRed, .winLongCatchRed:
			return "先胜"
		case .winNormalBlack, .winLongCatchBlack:
			return "先负"
		}
	}
	
}

// MARK: - Luna_Move
extension Luna_Move {
	
	public var from: Luna_Location {
		return Luna_Location(self >> 8)
	}
	
	public var to: Luna_Location {
		return Luna_Location(self & 0xff)
	}
	
}

// MARK: - LunaRecord
extension LunaRecord {
	
	var item: CharacterView.DataItem {
		return CharacterView.DataItem(Int(self.chess), self.character, Int(self.eat))
	}
	
}
