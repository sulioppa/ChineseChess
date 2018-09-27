//
//  InputAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/26.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class InputAlertView: UIView {

	public typealias Action = (title: String, action:(String) -> Void)
	
	private lazy var bar: NavigationBar = NavigationBar(superview: self)
	private weak var textField: UITextField? = nil
	
	private var leftAction: ((String) -> Void)? = nil
	private var rightAction: ((String) -> Void)? = nil
	
	public init(title: String, placeholder: String, left: Action, right: Action) {
		super.init(frame: .zero)
		self.separtedBorder()
		self.backgroundColor = .white
		
		self.bar.title = title
		self.leftAction = left.action
		self.rightAction = right.action
		
		// button
		func createButton() -> UIButton {
			let button = UIButton()
			button.backgroundColor = .white
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitleColor(.china, for: .normal)
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
		
		var button = createButton()
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
		
		button = createButton()
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
		
		let inputView: UITextField = {
			let view = UITextField()
			view.borderStyle = .bezel
			view.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			view.textColor = UIColor.carbon
			view.placeholder = placeholder
			view.delegate = self
			view.returnKeyType = .done
			return view
		}()
		
		self.addSubview(inputView)
		inputView.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.height.equalTo(layout.chessSize)
			$0.top.equalTo(self.bar.snp.bottom).offset(layout.chessSize / 2.0)
			$0.bottom.equalTo(button.snp.top).offset(-layout.chessSize / 2.0)
			$0.left.equalTo(self).offset(layout.boardmargin)
			$0.right.equalTo(self).offset(-layout.boardmargin)
		}
		
		self.textField = inputView
		
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
			self?.keyboardWillShow(sender: notification)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
		
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc private func didClickButton(sender: UIButton) {
		self.hide(animated: true)
		
		let text = self.textField?.text ?? ""
		if sender.tag == 0 {
			self.leftAction?(text)
		} else {
			self.rightAction?(text)
		}
	}
	
	private var backgroundView: UIView {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
		return view
	}
	
	public func show(in superview: UIView? = UIWindow.window) {
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
	
	private func hide(animated: Bool) {
		guard let superview = self.superview else { return }
		
		guard animated else {
			superview.removeFromSuperview()
			return
		}
		
		self.isUserInteractionEnabled = false
		UIView.animate(withDuration: Macro.Time.alertViewShowTime, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .allowUserInteraction, animations: {
			self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		}) { (_) in
			superview.removeFromSuperview()
		}
	}

	private func keyboardWillShow(sender: Notification) {
		guard let superview = self.superview else { return }
		
        guard let endRect = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		
        guard let lastTime = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
		
		guard let keyboardRect = self.window?.convert(endRect, to: superview) else { return }
		
		guard keyboardRect.minY < self.frame.maxY else { return }
		
		UIView.animate(withDuration: lastTime) {
			self.snp.updateConstraints {
				$0.centerY.equalTo(superview).offset(LayoutPartner.safeAreaCenterYOffset - (self.frame.maxY - keyboardRect.minY) - 10.0)
			}
			superview.layoutIfNeeded()
		}
	}
	
}

// MARK: -
extension InputAlertView: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
}
