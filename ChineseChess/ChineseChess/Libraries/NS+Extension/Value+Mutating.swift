//
//  Value+Offset.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/15.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension CGSize {
		
	public mutating func offset(width: CGFloat, height: CGFloat) -> CGSize {
		self.width += width
		self.height += height
		return self
	}
	
}

extension Bool {
	
	public mutating func reverse() -> Bool {
		self = !self
		return self
	}
	
}

