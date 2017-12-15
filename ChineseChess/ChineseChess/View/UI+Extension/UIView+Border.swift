//
//  UIView+Border.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/15.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIView {
	
	public func separtedBorder() {
		self.layer.cornerRadius = 5.0
		self.layer.borderWidth = 1.5
		self.layer.borderColor = UIColor.separtor.cgColor
		self.layer.masksToBounds = true
	}
	
}
