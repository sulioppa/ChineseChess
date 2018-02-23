//
//  UIView+Window.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIWindow {
	
	public static var window: UIWindow? {
		return UIApplication.shared.windows.first
	}
	
}
