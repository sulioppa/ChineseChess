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
		public static let transitionLastTime: TimeInterval = 0.75
	}
	
	public struct UI {
		public static let goldenScale: CGFloat = 0.618
		public static let fontName = "STKaiti"
	}
	
	public struct Project {
		public static let name = "ChineseChess"
	}
	
}
