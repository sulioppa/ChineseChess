//
//  BladeAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/17.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class BladeAlertView: UIView {
	
	private static let shared: BladeAlertView = BladeAlertView()
	
	private weak var textLabel: UILabel?
	private weak var blade: UIImageView?
	
	private init() {
		super.init(frame: CGRect.zero)
		self.backgroundColor = UIColor.clear
		
		guard let image = ResourcesProvider.shared.image(named: "prompt") else { return }
		
		let blade = UIImageView(image: image)
		
		let label: UILabel = {
			let view = UILabel()
			view.backgroundColor = UIColor.clear
			view.textColor = UIColor.separtor
			view.font = UIFont.kaitiFont(ofSize: LayoutPartner.ChessVC().buttonTitleFontSize)
			return view
		}()
		
		self.addSubview(blade)
		
		blade.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.centerY.equalTo(self)
			$0.width.equalTo(self).offset(-LayoutPartner.ChessBoard().boardmargin * 2)
			$0.height.equalTo(blade.snp.width).multipliedBy(image.size.height / image.size.width)
		}
		
		self.addSubview(label)
		label.snp.makeConstraints {
			$0.center.equalTo(blade.snp.center)
		}
		
		self.textLabel = label
		self.blade = blade
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func show(in superview: UIView, text: String, completion: (() -> Void)?) {
		self.textLabel?.text = text
		
		superview.addSubview(self)
		
		self.blade?.snp.updateConstraints({
			$0.centerX.equalTo(self).offset(LayoutPartner.safeArea.size.width)
		})
		
		self.snp.makeConstraints {
			$0.edges.equalTo(superview)
		}
		
		superview.layoutIfNeeded()

		UIView.animate(withDuration: Macro.Time.alertViewShowTime, animations: {
			self.blade?.snp.updateConstraints({
				$0.centerX.equalTo(self)
			})
			self.layoutIfNeeded()
		}) { (_) in
			DispatchQueue.main.asyncAfter(deadline: Macro.Time.alertViewSuspendTime.intValue.dispatchTime, execute: {
				self.hide() {
					completion?()
				}
			})
		}
	}
	
	@objc private func hide(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: Macro.Time.alertViewHideTime, animations: {
			self.blade?.snp.updateConstraints({
				$0.centerX.equalTo(self).offset(-LayoutPartner.safeArea.size.width)
			})
			self.layoutIfNeeded()
		}) { (_) in
			self.removeFromSuperview()
			completion?()
		}
	}
	
}

// MARK: - Public
extension BladeAlertView {
	
	public class func show(in view: UIView, text: String, completion: (() -> Void)? = nil) {
		BladeAlertView.shared.show(in: view, text: text, completion: completion)
	}
	
}
