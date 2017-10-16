//
//  LayoutPartner.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class LayoutPartner: NSObject {

	public static let height: CGFloat = {
		if UIScreen.main.bounds.size.height == 812.0 {
			return 734.0
		}
		return UIScreen.main.bounds.size.height
	}()
	
	public static let width: CGFloat = UIScreen.main.bounds.size.width
	
	public static let scale: CGFloat = LayoutPartner.width / 320.0
	
	// VC
	public struct Home {
		public var buttonSize: CGSize = CGSize(width: 130.0, height: 40)
		public var buttonCordins: CGFloat = 6.0
		public var buttonTitleFontSize: CGFloat = 20.0
		public var buttonSpace: CGFloat = 20
		
		public var titleViewSize: CGSize = CGSize.zero
		public var titleViewSpace: CGFloat = 45
		
		init() {
			self.buttonSize.width *= LayoutPartner.scale
			self.buttonSize.height *= LayoutPartner.scale
			self.buttonCordins *= LayoutPartner.scale
			self.buttonTitleFontSize *= LayoutPartner.scale
			self.buttonSpace *= LayoutPartner.scale
			
			self.titleViewSize.width = LayoutPartner.width * Macro.UI.goldenScale
			self.titleViewSize.height = self.titleViewSize.width * 0.25
			self.titleViewSpace *= LayoutPartner.scale
		}
	}
	
}
