//
//  LoadingAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class LoadingAlertView: UIView {

	private static let shared: LoadingAlertView = LoadingAlertView(frame: CGRect(x: 0, y: 0, width: LayoutPartner.width, height: LayoutPartner.height))
	
	private weak var loading: UIImageView? = nil
	private weak var titleLabel: UILabel? = nil
	private weak var closeView: UIView? = nil
	
	// Layout
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.black
		
		if let close = ResourcesProvider.shared.image(named: "close") {
			let imageView = UIImageView(image: close)
			imageView.contentMode = .scaleAspectFit
			imageView.frame = CGRect(x: 15, y: 15, width: close.size.width, height: close.size.height)
			
			self.closeView = imageView
			self.addSubview(imageView)
		}
		
		guard let loading = ResourcesProvider.shared.image(named: "loading") else { return }
		
		let layout = LayoutPartner.Home()
		
		let imageView = UIImageView(image: loading)
		self.loading = imageView
		self.addSubview(imageView)
		imageView.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.centerY.equalTo(self.snp.centerY).offset(-layout.buttonSpace)
			$0.size.equalTo(CGSize(width: self.bounds.size.width * (1 - Macro.UI.goldenScale), height: self.bounds.size.width * (1 - Macro.UI.goldenScale)))
		}
	
		let label = UILabel()
		self.titleLabel = label
		label.textColor = UIColor.white
		label.font = UIFont.kaitiFont(ofSize: layout.buttonTitleFontSize)
		label.text = ""
		self.addSubview(label)
		label.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.top.equalTo(imageView.snp.bottom).offset(layout.buttonSpace)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var animation: CABasicAnimation {
		let rotate = CABasicAnimation(keyPath: "transform")
		rotate.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
		rotate.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat.pi / 2.0, 0.0, 0.0, 1.0))
		rotate.repeatCount = HUGE
		rotate.isCumulative = true
		rotate.duration = 0.25
		return rotate
	}
	
}

// MARK: - Function
extension LoadingAlertView {
	
	public func show(in superview: UIView? = UIApplication.shared.windows.first, message: String? = nil, isCloseButtonHidden: Bool = true, completion: (() -> Void)? = nil) {
		guard let superview = superview else { return }
		
		self.removeFromSuperview()
		
		self.closeView?.isHidden = isCloseButtonHidden
		
		self.titleLabel?.text = message
		self.loading?.layer.removeAllAnimations()
		self.loading?.layer.add(self.animation, forKey: "rotate")
		self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.0)
		
		superview.addSubview(self)
		
		UIView.animate(withDuration: Macro.Time.transitionLastTime, animations: {
			self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
		}) { _ in
			completion?()
		}
	}
	
	public func hide(animation: Bool = true, completion: (() -> Void)? = nil) {
		guard animation else {
			self.removeFromSuperview()
			self.loading?.layer.removeAllAnimations()
			completion?()
			return
		}
		
		self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
		UIView.animate(withDuration: Macro.Time.transitionLastTime / 2.0, animations: {
			self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.0)
		}) { _ in
			self.removeFromSuperview()
			self.loading?.layer.removeAllAnimations()
			completion?()
		}
	}
	
}

// MARK: - Static
extension LoadingAlertView {
	
	public class func show(in superview: UIView? = UIApplication.shared.windows.first, message: String? = nil, isCloseButtonHidden: Bool = true, completion: (() -> Void)? = nil) {
		LoadingAlertView.shared.show(in: superview, message: message, isCloseButtonHidden: isCloseButtonHidden, completion: completion)
	}
	
	public class func hide(animation: Bool = true, completion: (() -> Void)? = nil) {
		LoadingAlertView.shared.hide(animation: animation, completion: completion)
	}
	
}
