//
//  Value+Meta.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/17.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension DispatchTime: ExpressibleByIntegerLiteral {
	
	public init(integerLiteral value: Int) {
		self = .now() + .seconds(value)
	}
	
}

extension Int {
	
	public var dispatchTime: DispatchTime {
		return DispatchTime(integerLiteral: self)
	}
	
}

extension TimeInterval {
	
	public var intValue: Int {
		return Int(self)
	}
	
}


