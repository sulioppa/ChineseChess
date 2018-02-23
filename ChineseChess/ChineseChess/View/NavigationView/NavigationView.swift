//
//  NavigationView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/23.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

public class NavigationView: UIView {
	
	public final lazy var bar: NavigationBar = NavigationBar(superview: self)
	
	// other subviews should add to the contentView
	public final lazy var contentView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		view.layer.masksToBounds = true
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.separtedBorder()
		self.backgroundColor = UIColor(white: 1.0, alpha: LayoutPartner.NavigationView().backgroundColorAlpha)
		self.isUserInteractionEnabled = true
		
		self.bar.leftBarButtonItem?.addTapTarget(self, action: #selector(self.dismiss(withVoice:)))
		
		self.addSubview(self.contentView)
		self.contentView.snp.makeConstraints {
			$0.top.equalTo(self.bar.snp.bottom)
			$0.left.equalTo(self)
			$0.bottom.equalTo(self)
			$0.right.equalTo(self)
		}
		
		NotificationCenter.default.addObserver(forName: Macro.NotificationName.willShowAnotherAlertView, object: nil, queue: OperationQueue.main) { [weak self] (_) in
			self?.dismiss(withVoice: nil)
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private var backgroundView: UIView {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0, alpha: 0)
		return view
	}
	
	@objc public final func show(in superview: UIView? = UIWindow.window, withVoice: Any? = true) {
		guard self.superview == nil, self.isUserInteractionEnabled, let window = superview else { return }
		
		self.isUserInteractionEnabled = false
		if withVoice != nil {
			WavHandler.playButtonWav()
		}
		
		let backgroundView = self.backgroundView
		window.addSubview(backgroundView)
		backgroundView.snp.makeConstraints {
			$0.edges.equalTo(window)
		}
		
		backgroundView.addSubview(self)
		self.snp.makeConstraints {
			$0.centerY.equalTo(backgroundView).offset(LayoutPartner.safeAreaCenterYOffset)
			$0.centerX.equalTo(backgroundView.snp.centerX).offset(LayoutPartner.safeArea.size.width)
		}
		backgroundView.layoutIfNeeded()
		
		UIView.animate(withDuration: Macro.Time.alertViewShowTime, animations: {
			self.snp.updateConstraints {
				$0.centerX.equalTo(backgroundView.snp.centerX)
			}
			backgroundView.backgroundColor = backgroundView.backgroundColor?.withAlphaComponent(0.5)
			backgroundView.layoutIfNeeded()
		}) { (_) in
			self.isUserInteractionEnabled = true
		}
	}
	
	@objc public final func push(view: NavigationView) {
		guard let superview = self.superview, self.isUserInteractionEnabled, self != view else { return }
		
		self.isUserInteractionEnabled = false
		WavHandler.playButtonWav()
		
		superview.addSubview(view)
		view.snp.makeConstraints {
			$0.centerY.equalTo(superview).offset(LayoutPartner.safeAreaCenterYOffset)
			$0.centerX.equalTo(superview.snp.centerX).offset(LayoutPartner.safeArea.size.width)
		}
		superview.layoutIfNeeded()
		
		UIView.animate(withDuration: Macro.Time.alertViewShowTime, animations: {
			self.snp.updateConstraints {
				$0.centerX.equalTo(superview.snp.centerX).offset(-LayoutPartner.safeArea.size.width)
			}
			
			view.snp.updateConstraints {
				$0.centerX.equalTo(superview.snp.centerX)
			}
			superview.layoutIfNeeded()
		}) { (_) in
			self.removeFromSuperview()
		}
	}
	
	@objc public final func dismiss(withVoice: Any? = true) {
		guard let superview = self.superview else { return }
		
		self.isUserInteractionEnabled = false
		if withVoice != nil {
			WavHandler.playButtonWav()
		}
		
		UIView.animate(withDuration: Macro.Time.alertViewHideTime, animations: {
			self.snp.updateConstraints {
				$0.centerX.equalTo(superview.snp.centerX).offset(-LayoutPartner.safeArea.size.width)
			}
			superview.backgroundColor = superview.backgroundColor?.withAlphaComponent(0)
			superview.layoutIfNeeded()
		}) { (_) in
			superview.removeFromSuperview()
		}
	}
	
}

// MARK: - NavigationBar
public final class NavigationBar: UIView {

	public final lazy var leftBarButtonItem: UIImageView? = { [weak self] in
		guard let `self` = self else { return nil }
		
		let item = self.barButtonItem()
		item.image = ResourcesProvider.shared.image(named: "back")
		self.addSubview(item)
		item.snp.makeConstraints {
			$0.left.equalTo(self)
			$0.top.equalTo(self)
			$0.bottom.equalTo(self)
			$0.width.equalTo(self.snp.height)
		}
		return item
	}()
	
	public final lazy var rightBarButtonItem: UIImageView? = { [weak self] in
		guard let `self` = self else { return nil }
		
		let item = self.barButtonItem()
		self.addSubview(item)
		item.snp.makeConstraints {
			$0.right.equalTo(self)
			$0.top.equalTo(self)
			$0.bottom.equalTo(self)
			$0.width.equalTo(self.snp.height)
		}
		return item
		}()
	
	public var title: String {
		set {
			self.titleView.text = newValue
		}
		
		get {
			return self.titleView.text ?? ""
		}
	}
	
	private lazy var titleView: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.white
		label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().titleFontSize)
		label.numberOfLines = 1
		return label
	}()
	
	public init(superview: UIView) {
		super.init(frame: CGRect.zero)
		self.separtedBorder()
		self.backgroundColor = UIColor.china
		
		superview.addSubview(self)
		self.snp.makeConstraints {
			$0.top.equalTo(superview)
			$0.left.equalTo(superview)
			$0.right.equalTo(superview)
			$0.height.equalTo(44.0)
		}
		
		self.addSubview(self.titleView)
		self.titleView.snp.makeConstraints {
			$0.center.equalTo(self)
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func barButtonItem() -> UIImageView {
		let imageView = UIImageView()
		imageView.backgroundColor = UIColor.clear
		imageView.contentMode = .center
		imageView.layer.masksToBounds = true
		return imageView
	}
	
}
