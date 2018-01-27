//
//  PromptAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/26.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class PromptAlertView: UIView {

	public typealias Action = (title: String, isDestructive: Bool, action: () -> Void)
	
	private lazy var bar: NavigationBar = NavigationBar(superview: self)
	private var leftAction: (() -> Void)? = nil
	private var rightAction: (() -> Void)? = nil
	
	public init(title: String, message: String, left: Action, right: Action) {
		super.init(frame: .zero)
		self.separtedBorder()
		self.backgroundColor = .white
		
		self.bar.title = title
		self.leftAction = left.action
		self.rightAction = right.action
		
		// button
		func createButton(isRed: Bool = false) -> UIButton {
			let button = UIButton()
			button.backgroundColor = isRed ? .red : .white
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitleColor(isRed ? .white : .china, for: .normal)
			button.setTitleColor(.red, for: .highlighted)
			return button
		}
		
		let layout = LayoutPartner.ChessBoard()
		var line = UIView()
		line.backgroundColor = UIColor.separtor
		self.addSubview(line)
		line.snp.makeConstraints {
			$0.centerX.equalTo(self.snp.centerX)
			$0.bottom.equalTo(self)
			$0.height.equalTo(layout.chessSize)
			$0.width.equalTo(0.5)
		}
		
		var button = createButton(isRed: left.isDestructive)
		button.tag = 0
		button.setTitle(left.title, for: .normal)
		button.addTarget(self, action: #selector(self.didClickButton(sender:)), for: .touchUpInside)
		self.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(self)
			$0.bottom.equalTo(self)
			$0.right.equalTo(line.snp.left)
			$0.height.equalTo(layout.chessSize)
		}
		
		button = createButton(isRed: right.isDestructive)
		button.tag = 1
		button.setTitle(right.title, for: .normal)
		button.addTarget(self, action: #selector(self.didClickButton(sender:)), for: .touchUpInside)
		self.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(line.snp.right)
			$0.bottom.equalTo(self)
			$0.right.equalTo(self)
			$0.height.equalTo(layout.chessSize)
		}
		
		line = UIView()
		line.backgroundColor = UIColor.separtor
		self.addSubview(line)
		line.snp.makeConstraints {
			$0.left.equalTo(self)
			$0.right.equalTo(self)
			$0.height.equalTo(0.5)
			$0.bottom.equalTo(button.snp.top)
		}
		
		let messageView: UILabel = {
			let label = UILabel()
			label.textColor = UIColor.black
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			label.numberOfLines = 0
			label.text = message
			label.lineBreakMode = .byWordWrapping
			label.preferredMaxLayoutWidth = LayoutPartner.safeArea.width - 4 * LayoutPartner.ChessBoard().boardmargin
			label.textAlignment = .center
			return label
		}()
		
		self.addSubview(messageView)
		messageView.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.top.equalTo(self.bar.snp.bottom).offset(layout.chessSize / 2.0)
			$0.bottom.equalTo(button.snp.top).offset(-layout.chessSize / 2.0)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func didClickButton(sender: UIButton) {
		self.hide()
		
		if sender.tag == 0 {
			self.leftAction?()
		} else {
			self.rightAction?()
		}
	}
	
	private var backgroundView: UIView {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
		return view
	}
	
	public func show(in superview: UIView? = UIView.window()) {
		guard let superview = superview else { return }
		self.isUserInteractionEnabled = false
		
		let backgroundView = self.backgroundView
		superview.addSubview(backgroundView)
		backgroundView.snp.makeConstraints {
			$0.edges.equalTo(superview)
		}
		
		let margin = LayoutPartner.ChessBoard().boardmargin
		backgroundView.addSubview(self)
		self.snp.makeConstraints {
			$0.centerY.equalTo(backgroundView).offset(LayoutPartner.safeAreaCenterYOffset)
			$0.centerX.equalTo(backgroundView.snp.centerX)
			$0.left.equalTo(backgroundView).offset(margin)
			$0.right.equalTo(backgroundView).offset(-margin)
		}
		
		self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
		backgroundView.backgroundColor = backgroundView.backgroundColor?.withAlphaComponent(0.0)
		
		UIView.animate(withDuration: Macro.Time.chessMoveLastTime, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .allowUserInteraction, animations: {
			self.transform = .identity
			backgroundView.backgroundColor = backgroundView.backgroundColor?.withAlphaComponent(0.5)
		}) { (_) in
			self.isUserInteractionEnabled = true
		}
	}
	
	private func hide() {
		guard let superview = self.superview else { return }
		self.isUserInteractionEnabled = false
		
		UIView.animate(withDuration: Macro.Time.alertViewShowTime, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .allowUserInteraction, animations: {
			self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		}) { (_) in
			superview.removeFromSuperview()
		}
	}
	
}
