//
//  UIView+Window.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIView {
	
	public class func window() -> UIWindow? {
		return UIApplication.shared.windows.first
	}
	
}
