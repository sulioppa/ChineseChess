//
//  Value+Random.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/23.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - Random
extension Double {
	public static func random() -> Double {
		return Double(arc4random()) / Double(UInt32.max)
	}
}

extension Float {
	public static func random() -> Float {
		return Float(Double.random())
	}
}

extension CGFloat {
	public static func random() -> CGFloat {
		return CGFloat(Double.random())
	}
}
