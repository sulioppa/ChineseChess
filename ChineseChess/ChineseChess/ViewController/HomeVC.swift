//
//  HomeVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/11.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import SnapKit

class HomeVC: UIViewController {

	fileprivate lazy var scrollVC: ScrollVC = ScrollVC()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.black
		self.initScrollView()
		self.initEntrances()
    }
	
	// Scrollview
	private func initScrollView() {
		self.view.addSubview(self.scrollVC.scrollView)
		self.scrollVC.scrollView.snp.makeConstraints {
			$0.top.equalTo(self.snp.top)
			$0.left.equalTo(self.snp.left)
			$0.bottom.equalTo(self.snp.bottom)
			$0.right.equalTo(self.snp.right)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
	}
	
	// Entrances
	private func initEntrances() {
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
}

// MARK: - Action
extension HomeVC {
	
	@objc func presentVC(sender: Any?) {
		guard let tag = (sender as? UIButton)?.tag else { return }
		switch tag {
		case 1:
			self.present("GameVC")
		case 2:
			self.present("HistoryVC")
		case 3:
			self.present("MultiPeerVC")
		default:
			fatalError("Unknown sender trigger this function: \(#function), check the button's tag")
		}
	}
	
}

// MARK: - ScrollView Scroll Control
extension HomeVC {
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.scrollVC.isViewAppear = true
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.scrollVC.isViewAppear = false
	}
	
	@objc func applicationWillEnterForeground() {
		self.scrollVC.isForeground = true
	}
	
	@objc func applicationDidEnterBackground() {
		self.scrollVC.isForeground = false
	}
	
}

// MARK: - ScrollViewController
extension HomeVC {
	
	fileprivate class ScrollVC: NSObject {
		
		// Public vars
		public var isForeground: Bool = true {
			didSet {
				if !oldValue {
					self.scrollViewShouldBeginScroll()
				}
			}
		}
		
		public var isViewAppear: Bool = false {
			didSet {
				if !oldValue {
					self.scrollViewShouldBeginScroll()
				}
			}
		}
		
		public var scrollView: UIScrollView {
			return self.view
		}
		
		// Private vars
		private lazy var view: UIScrollView = {
			let scrollView = UIScrollView()
			scrollView.backgroundColor = UIColor.white
			scrollView.showsVerticalScrollIndicator = false
			scrollView.showsHorizontalScrollIndicator = false
			scrollView.bounces = false
			scrollView.isScrollEnabled = false
			scrollView.isUserInteractionEnabled = false
			
			if let image = ResourcesProvider.shared.image(named: "home") {
				let contentSize = CGSize(width: Macro.UI.height * image.size.width / image.size.height, height: Macro.UI.height)
				let imageView = UIImageView(image: image)
				imageView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
				
				scrollView.contentSize = contentSize
				scrollView.addSubview(imageView)
			}
			return scrollView
		}()
		
		private var direction: CGFloat = 1.0
		private var currentOffset: CGFloat = 0.0
		
		@objc func scrollViewShouldBeginScroll() {
			guard self.isViewAppear && self.isForeground else { return }
			
			let targetOffset = self.currentOffset + self.direction
			if targetOffset > scrollView.contentSize.width - Macro.UI.width {
				self.direction = -1.0
			} else if(targetOffset + self.direction < 0.0) {
				self.direction = 1.0
			}
			
			self.currentOffset += self.direction
			scrollView.setContentOffset(CGPoint(x: self.currentOffset, y: 0), animated: true)
			self.perform(#selector(scrollViewShouldBeginScroll), with: nil, afterDelay: Macro.Time.homeScrollInterval)
		}
		
	}

}
