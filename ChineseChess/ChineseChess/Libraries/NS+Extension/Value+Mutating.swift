//
//  Value+Offset.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/15.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension CGSize {
		
	public mutating func offset(width: CGFloat, height: CGFloat) {
		self.width += width
		self.height += height
	}
	
	public mutating func contained(in size: CGSize) {
		if self.width > size.width {
			self.width = size.width
		}
		
		if self.height > size.height {
			self.height = size.height
		}
	}
	
}

extension Bool {
	
	public mutating func reverse() -> Bool {
		self = !self
		return self
	}
	
}

