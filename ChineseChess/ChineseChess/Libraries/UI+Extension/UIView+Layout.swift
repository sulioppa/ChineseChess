//
//  UIView+Layout.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/18.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
	
	// MARK: - Layout. if this view belongs to ViewController, you should to use self.layout.
	open var layout: ConstraintAttributesDSL {
		if #available(iOS 11.0, *) {
			return self.safeAreaLayoutGuide.snp
		} else {
			return self.snp
		}
	}
	
}
