//
//  UIButton+Golden.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIButton {
	
	public class func gold(cornerRadius: CGFloat) -> UIButton {
		let button = UIButton(type: .custom)
		button.layer.cornerRadius = cornerRadius
		button.setBackgroundImage(ResourcesProvider.shared.image(named: "button"), for: .normal)
		return button
	}
	
}
