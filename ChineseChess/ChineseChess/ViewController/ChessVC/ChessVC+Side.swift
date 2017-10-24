//
//  ChessVC+Side.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - top and bottom Side Operation.
extension ChessVC {
	
	public enum SideState: Int {
		case AI = -1
		case red
		case black
		
		var image: UIImage? {
			switch self {
			case .AI:
				return ResourcesProvider.shared.image(named: "AI")
			case .red:
				return ResourcesProvider.shared.image(named: "帥")
			case .black:
				return ResourcesProvider.shared.image(named: "將")
			}
		}
	}
	
	public final func setSideState(top: SideState, bottom: SideState) {
		self.topSide.image = top.image
		self.bottomSide.image = bottom.image
	}
	
	public final func setNickname(top: String, bottom: String) {
		self.topNickname.text = top
		self.bottomNickname.text = bottom
	}
	
}
