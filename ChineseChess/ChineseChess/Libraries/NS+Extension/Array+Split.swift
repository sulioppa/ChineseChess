//
//  Array+Split.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/20.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension Array {
	
	subscript (range: CountableClosedRange<Int>) -> [Element]? {
		guard range.lowerBound >= 0 && range.upperBound < self.endIndex && self.count > 0 else { return nil }
		
		var split: [Element] = []
		for index in range.sorted() {
			split.append(self[index])
		}
		return split
	}
	
}
