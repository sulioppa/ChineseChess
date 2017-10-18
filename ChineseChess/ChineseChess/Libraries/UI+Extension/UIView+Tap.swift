//
//  UIView+Tap.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/18.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - TapAction.
extension UIView {
	
	public func addTapTarget(_ target: Any?, action: Selector) {
		let tap = UITapGestureRecognizer(target: target, action: action)
		tap.numberOfTapsRequired = 1
		tap.numberOfTouchesRequired = 1
		self.addGestureRecognizer(tap)
		self.isUserInteractionEnabled = true
	}
	
}
