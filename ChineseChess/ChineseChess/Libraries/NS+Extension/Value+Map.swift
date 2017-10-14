//
//  Value+Map.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

infix operator <-

extension Bool {
	
	public static func <- (_ left: inout Bool, _ right: Any?) {
		guard let value = right as? Bool else { return }
		left = value
	}
	
}

extension Int {
	
	public static func <- (_ left: inout Int, _ right: Any?) {
		guard let value = right as? Int else { return }
		left = value
	}
	
}

extension String {
	
	public static func <- (_ left: inout String, _ right: Any?) {
		guard let value = right as? String else { return }
		left = value
	}
	
}

extension Dictionary {
	
	public static func <- (_ left: inout Dictionary, _ right: Any?) {
		guard let value = right as? Dictionary else { return }
		left = value
	}
	
}


