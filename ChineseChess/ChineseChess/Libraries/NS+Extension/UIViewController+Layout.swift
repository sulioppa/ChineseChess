//
//  UIViewController+Layout.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/12.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import SnapKit

@available(iOS 10.0, *)
extension UIViewController {

	var snp: ConstraintAttributesDSL {
		if #available(iOS 11.0, *) {
			return self.view.safeAreaLayoutGuide.snp
		} else {
			return self.view.snp
		}
	}
	
}
