//
//  TextAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class TextAlertView: UIView {
	
	private static let shared: TextAlertView = TextAlertView()
	
	private lazy var textLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = UIColor(white: 0, alpha: 0.5)
		label.textColor = UIColor.white
		return label
	}()
	
	private init() {
		super.init(frame: CGRect.zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func show(text: String) {
		self.textLabel.text = text
	}
	
}

// MARK: - Public
extension TextAlertView {
	
	public class func show(text: String) {
		TextAlertView.shared.show(text: text)
	}
	
}
