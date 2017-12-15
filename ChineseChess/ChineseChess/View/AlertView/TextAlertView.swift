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
	
	private lazy var textView: UITextView = {
		let view = UITextView()
		view.backgroundColor = UIColor(white: 0, alpha: 0.625)
		view.textColor = UIColor.white
		view.font = UIFont.kaitiFont(ofSize: LayoutPartner.ChessVC().buttonTitleFontSize)
		view.isEditable = false
		view.isSelectable = false
		view.separtedBorder()
		return view
	}()
	
	private init() {
		super.init(frame: CGRect.zero)
		self.backgroundColor = UIColor.clear
		
		self.addSubview(self.textView)
		self.textView.snp.makeConstraints {
			$0.center.equalTo(self)
			$0.size.equalTo(CGSize.zero)
		}
		
		self.addTapTarget(self, action: #selector(self.hide))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func show(in view: UIView, text: String) {
		self.isUserInteractionEnabled = false
		self.textView.text = text
		
		let size = self.textView.sizeThatFits(CGSize(width: LayoutPartner.safeArea.size.width - 40.0, height: LayoutPartner.safeArea.size.height - 40.0))
		self.textView.snp.updateConstraints {
			$0.size.equalTo(size)
		}
		
		view.addSubview(self)
		self.snp.makeConstraints {
			$0.edges.equalTo(view)
		}
		
		self.isUserInteractionEnabled = true
	}
	
	@objc private func hide() {
		self.removeFromSuperview()
	}
	
}

// MARK: - Public
extension TextAlertView {
	
	public class func show(in view: UIView, text: String) {
		TextAlertView.shared.show(in: view, text: text)
	}
	
}
