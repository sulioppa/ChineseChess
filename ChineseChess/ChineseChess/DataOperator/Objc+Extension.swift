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
        
        @unknown default:
            return "状态未知"
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
            
        @unknown default:
            return "结果: 未知"
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
        
        @unknown default:
            return "-"
        }
	}
	
}

// MARK: - Bool, Side
extension Bool {
	
	public var isRed: Bool {
		return !self
	}
	
}

// MARK: - LunaMove
extension LunaMove {
	
	public var from: LunaLocation {
		return LunaLocation(self >> 8)
	}
	
	public var to: LunaLocation {
		return LunaLocation(self & 0xff)
	}
	
}

// MARK: - LunaChess
extension LunaChess {
	
	public var name: String {
		switch self {
		case 16:
			return "帥"
		case 32:
			return "將"
			
		case 17, 18:
			return "仕"
		case 33, 34:
			return "士"
			
		case 19, 20:
			return "相"
		case 35, 36:
			return "象"
			
		case 21, 22, 37, 38:
			return "馬"
			
		case 23, 24, 39, 40:
			return "車"
			
		case 25, 26:
			return "炮"
		case 41, 42:
			return "砲"
			
		case 27, 28, 29, 30, 31:
			return "兵"
		case 43, 44, 45, 46, 47:
			return "卒"
		
		default:
			return ""
		}
	}
	
}

// MARK: - LunaRecord
extension LunaRecord {
	
	var item: CharacterView.DataItem {
		return CharacterView.DataItem(Int(self.chess), self.character, Int(self.eat))
	}
	
}

// MARK: - LunaPutChessState
extension LunaPutChessState {
	
	public func description(name: String) -> String {
		switch self {
		case .wrongPut:
			return "\(name)不能放在这里"
		case .wrongEat:
			return "\(name)不能被移除"
		default:
			return ""
		}
	}
	
}

// MARK: - LunaEditDoneState
extension LunaEditDoneState {
	
	public func description(state: LunaBoardState) -> String {
		
		switch self {
		case .wrongFaceToFace:
			return "帥將照面"
		case .wrongIsCheckedMate:
			return "\(state == .turnRedSide ? "红方" : "黑方")无子可走"
		case .wrongCheck:
			return "\(state == .turnRedSide ? "將" : "帥")被将军"
		default:
			return ""
		}
	}
	
}
