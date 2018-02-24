//
//  MultiPeerJson.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/30.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class MultiPeerJson: NSObject {

	public enum MessageType: Int {
		case newGame = 0
		case ready
		case move
		case lose
		case chat
		case request
		case response
		case regret
		case draw
		case turndown
	}
	
	public class func json(type: MessageType, parameters: [String: Any]) -> [String: Any] {
		return ["type": type.rawValue, "data": parameters]
	}
	
	public class func type(json: [String: Any], block: (MessageType, [String: Any]) -> Void) {
		var rawValue = 0
		rawValue <- json["type"]
		
		guard let type = MessageType(rawValue: rawValue), let parameters = json["data"] as? [String: Any] else { return }
		block(type, parameters)
	}
	
}
