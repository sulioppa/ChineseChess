//
//  UIViewController+PresentVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
extension UIViewController {
	
	public func present(_ viewControllerToPresent: String, completion: (() -> Void)? = nil) {
		LoadingAlertView.show(in: self.view) {
			if let vc = NSObject.instance(from: viewControllerToPresent) as? UIViewController {
				self.present(vc, animated: true) {
					LoadingAlertView.hide(animation: false, completion: completion)
				}
			} else {
				fatalError("not found class named '\(viewControllerToPresent)'")
			}
		}
	}
	
	public func present(_ viewControllerToPresent: UIViewController, completion: (() -> Void)? = nil) {
		LoadingAlertView.show(in: self.view) {
			self.present(viewControllerToPresent, animated: true) {
				LoadingAlertView.hide(animation: false, completion: completion)
			}
		}
	}
	
	public func dismiss(completion: (() -> Void)? = nil) {
		LoadingAlertView.show(in: self.view) {
			self.dismiss(animated: true) {
				LoadingAlertView.hide(animation: false, completion: completion)
			}
		}
	}
	
}

