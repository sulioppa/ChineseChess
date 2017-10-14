//
//  Settings.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - Macro
public struct Macro {

	public struct Time {
		public static let launchLastTime: TimeInterval = 1.625
		public static let homeScrollInterval: TimeInterval = 1.0 / 25.0
	}
	
	public struct UI {
		public static var height: CGFloat {
			if UIScreen.main.bounds.size.height == 812.0 {
				return 734.0
			}
			return UIScreen.main.bounds.size.height
		}
		
		public static var width: CGFloat {
			return UIScreen.main.bounds.size.width
		}
	}
	
}
