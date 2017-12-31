//
//  UIImage+Color.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/31.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension UIImage {
	
	public func image(blende color: UIColor, overlay: Bool = false) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
		defer {
			UIGraphicsEndImageContext()
		}
		
		color.setFill()
		UIRectFill(CGRect(origin: .zero, size: self.size))
		
		if overlay {
			self.draw(at: .zero, blendMode: .overlay, alpha: 1.0)
		}
		self.draw(at: .zero, blendMode: .destinationIn, alpha: 1.0)
		
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
}
