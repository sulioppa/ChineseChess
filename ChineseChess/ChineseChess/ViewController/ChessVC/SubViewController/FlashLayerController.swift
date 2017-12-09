//
//  FlashLayerController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/23.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class FlashLayerController: NSObject {
	private static let height: CGFloat = LayoutPartner.ChessBoard().gridSize - 4.0
	private static let width: CGFloat = 299.0 * height / 308.0
	
	public static var layer: (backgroundLayer: CAShapeLayer, progressLayer: CAShapeLayer) {
		func V(_ v: CGFloat) -> CGFloat {
			return v * height / 308.0
		}
		
		let layer = CAShapeLayer()
		layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
		layer.fillColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.75
		layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
		layer.shadowColor = UIColor.black.cgColor
		
		let path = CGMutablePath()
		path.addLines(between: [
			CGPoint(x: V(299.0), y: V(0.0)),
			CGPoint(x: V(86.0), y: V(130.0)),
			CGPoint(x: V(136.0), y: V(138.0)),
			CGPoint(x: V(51.0), y: V(205.0)),
			CGPoint(x: V(97.0), y: V(212.0)),
			CGPoint(x: V(0.0), y: V(308.0)),
			CGPoint(x: V(208.0), y: V(180.0)),
			CGPoint(x: V(152.0), y: V(172.0)),
			CGPoint(x: V(242.0), y: V(108.0)),
			CGPoint(x: V(193.0), y: V(99.0))
			])
		layer.path = path
		
		let progress = CAShapeLayer()
		progress.frame = layer.frame
		progress.mask = layer
		progress.fillColor = UIColor.gold.cgColor
		progress.path = self.rect(progress: 0.0)
		
		let background = CAShapeLayer()
		background.frame = layer.frame
		background.mask = layer
		background.fillColor = UIColor.china.cgColor
		background.path = self.rect(progress: 1.0)
		background.addSublayer(progress)
		
		return (background, progress)
	}
	
	public class func rect(progress: Float) -> CGPath {
		let path = CGMutablePath()
		let y: CGFloat = height * CGFloat(1.0 - progress)
		path.addRect(CGRect(x: 0, y: y, width: width, height: height - y))
		return path
	}
}
