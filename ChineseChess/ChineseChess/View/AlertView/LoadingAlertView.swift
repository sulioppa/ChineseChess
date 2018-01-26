//
//  LoadingAlertView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

protocol LoadingAlertViewDelegate: NSObjectProtocol {
	func loadingAlertViewDidDisappear(view: LoadingAlertView)
}

class LoadingAlertView: UIView {

	private static let shared: LoadingAlertView = LoadingAlertView(frame: CGRect.zero)
	
	private weak var loading: UIImageView? = nil
	private weak var titleLabel: UILabel? = nil
	private weak var closeView: UIView? = nil
	
	private weak var delegate: LoadingAlertViewDelegate? = nil
	
	// Layout
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.black
		
		guard let loading = ResourcesProvider.shared.image(named: "loading"), let close = ResourcesProvider.shared.image(named: "close") else { return }
		
		var imageView = UIImageView(image: loading)
		
		self.addSubview(imageView)
		imageView.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.bottom.equalTo(self.snp.centerY)
			$0.width.equalTo(self.snp.width).multipliedBy(1 - Macro.UI.goldenScale)
			$0.height.equalTo(self.snp.width).multipliedBy(1 - Macro.UI.goldenScale)
		}
		
		let layout = LayoutPartner.HomeVC()
		let label: UILabel = {
			let label = UILabel()
			label.font = UIFont.kaitiFont(ofSize: layout.buttonTitleFontSize)
			label.textColor = UIColor.white
			label.numberOfLines = 0
			label.preferredMaxLayoutWidth = LayoutPartner.safeArea.size.width - 30.0
			label.text = ""
			return label
		}()

		self.addSubview(label)
		label.snp.makeConstraints {
			$0.centerX.equalTo(self)
			$0.top.equalTo(imageView.snp.bottom).offset(layout.buttonSpace)
		}
		
		self.loading = imageView
		self.titleLabel = label
		
		imageView = {
			let imageView = UIImageView(image: close)
			imageView.contentMode = .center
			imageView.addTapTarget(self, action: #selector(self.closeAlertView))
			return imageView
		}()
		
		self.addSubview(imageView)
		imageView.snp.makeConstraints({
			$0.centerX.equalTo(self)
			$0.size.equalTo(CGSize(width: 40.0, height: 40.0))
			$0.top.equalTo(label.snp.bottom).offset(layout.buttonSpace)
		})
		
		self.closeView = imageView
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
	
	@objc private func closeAlertView() {
		self.hide() {
			self.delegate?.loadingAlertViewDidDisappear(view: self)
			self.delegate = nil
		}
	}
	
}

// MARK: - Function
extension LoadingAlertView {
	
	public func show(in superview: UIView? = UIView.window(), message: String? = nil, isCloseButtonHidden: Bool = true, delegate: LoadingAlertViewDelegate? = nil, completion: (() -> Void)? = nil) {
		guard let superview = superview else { return }
		
		self.removeFromSuperview()
		self.loading?.layer.removeAllAnimations()
		self.loading?.layer.add(self.animation, forKey: "rotate")
		self.titleLabel?.text = message
		self.closeView?.isHidden = isCloseButtonHidden
		
		self.delegate = delegate
		self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.0)
		
		superview.addSubview(self)
		self.snp.makeConstraints {
			$0.edges.equalTo(superview)
		}
		
		UIView.animate(withDuration: Macro.Time.transitionLastTime, animations: {
			self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.625)
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
		
		self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.625)
		UIView.animate(withDuration: Macro.Time.alertViewHideTime, animations: {
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
	
	public class func show(in superview: UIView? = UIView.window(), message: String? = nil, isCloseButtonHidden: Bool = true, delegate: LoadingAlertViewDelegate? = nil, completion: (() -> Void)? = nil) {
		LoadingAlertView.shared.show(in: superview, message: message, isCloseButtonHidden: isCloseButtonHidden, completion: completion)
	}
	
	public class func hide(animation: Bool = true, completion: (() -> Void)? = nil) {
		LoadingAlertView.shared.hide(animation: animation, completion: completion)
	}
	
}
