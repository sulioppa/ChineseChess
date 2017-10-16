//
//  UIButton+Golden.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIButton {
	
	public static var gold: UIButton {
		let button = UIButton(type: .custom)
		button.setBackgroundImage(ResourcesProvider.shared.image(named: "button"), for: .normal)
		button.layer.masksToBounds = true
		button.setTitleColor(UIColor.china, for: .normal)
		button.setTitleColor(UIColor.red, for: .highlighted)
		button.setTitleColor(UIColor.lightGray, for: .disabled)
		return button
	}
	
}
