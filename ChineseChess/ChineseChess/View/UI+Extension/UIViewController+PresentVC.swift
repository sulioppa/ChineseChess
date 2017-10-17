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
	
	public func present(_ viewControllerToPresent: String, animated: Bool = true, completion: (() -> Void)? = nil) {
		if animated {
			LoadingAlertView.show(in: self.view) {
				if let vc = NSClassFromString("\(Macro.Project.name).\(viewControllerToPresent)")?.alloc() as? UIViewController {
					self.present(vc, animated: animated) {
						LoadingAlertView.hide(completion: completion, animation: false)
					}
				} else {
					fatalError("not found class named '\(viewControllerToPresent)'")
				}
			}
		} else {
			if let vc = NSClassFromString("\(Macro.Project.name).\(viewControllerToPresent)")?.alloc() as? UIViewController {
				self.present(vc, animated: animated, completion: completion)
			} else {
				fatalError("not found class named '\(viewControllerToPresent)'")
			}
		}
	}
	
}

