//
//  UIFont+KaiTi.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIFont {
	
	public class func kaitiFont(ofSize size: CGFloat) -> UIFont? {
		return UIFont(name: Macro.UI.fontName, size: size)
	}
	
}
