//
//  Value+Property.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/2.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

extension Int {
	
	public var isEven: Bool {
		return (self & 1) == 0
	}
	
}

extension Date {
	
	public static var time: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyMMdd HH:mm:ss"
		return formatter.string(from: Date())
	}
	
}

extension String {
	
	public var noSpace: String {
		return self.replacingOccurrences(of: " ", with: "")
	}
	
	public static var uuid: String {
		return UUID().uuidString
	}
	
	public static var empty: String {
		return ""
	}
	
}

extension Bool {
	
	public var rawValue: Int {
		return self ? 1 : 0
	}
	
}
