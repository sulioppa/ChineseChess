//
//  ChessVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class ChessVC: UIViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.black
		self.modalTransitionStyle = .crossDissolve
		
		self.layoutContentView()
		self.layoutChessBoard()
    }
	
	// MARK: - SafaArea
	private lazy var safeArea: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.carbon
		return view
	}()
	
	private func layoutContentView() {
		self.view.addSubview(self.safeArea)
		self.safeArea.snp.makeConstraints {
			$0.top.equalTo(self.view.layout.top)
			$0.left.equalTo(self.view.layout.left)
			$0.bottom.equalTo(self.view.layout.bottom)
			$0.right.equalTo(self.view.layout.right)
		}
	}
	
	// MARK: - topWood、ChessBoard、bottomWood
	private lazy var topWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
	private lazy var chessBoard: UIImageView = UIImageView()
	private lazy var bottomWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
	
	private func layoutChessBoard() {
		guard let image = ResourcesProvider.shared.image(named: "board") else {
			fatalError("the image named board didn't find.")
		}
		
		self.chessBoard.image = image
		self.contentView.addSubview(self.chessBoard)
		self.chessBoard.snp.makeConstraints {
			$0.width.equalTo(self.contentView.snp.width)
			$0.height.equalTo(self.contentView.snp.width).multipliedBy(image.size.height / image.size.width)
			$0.center.equalTo(self.contentView.snp.center)
		}
		
		self.contentView.addSubview(self.topWood)
		self.topWood.snp.makeConstraints {
			$0.top.equalTo(self.contentView)
			$0.left.equalTo(self.contentView)
			$0.bottom.equalTo(self.chessBoard.snp.top)
			$0.right.equalTo(self.contentView)
		}
		
		self.contentView.addSubview(self.bottomWood)
		self.bottomWood.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0.0, 0.0, 1.0)
		self.bottomWood.snp.makeConstraints {
			$0.top.equalTo(self.chessBoard.snp.bottom)
			$0.left.equalTo(self.contentView)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(self.contentView)
		}
	}

}

// MARK: - attributes are visible to child class
extension ChessVC {
	
	// subviews should add to this 'contentView'
	public var contentView: UIView {
		return self.safeArea
	}
	
}

// MARK: - Chess Operation
extension ChessVC {
	
}
