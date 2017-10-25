//
//  ChessVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - Chess View Controller (Super Class)
class ChessVC: UIViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.black
		self.modalTransitionStyle = .crossDissolve
		
		self.layoutContentView()
		self.layoutChessBoard()
		self.layoutFlashLayer()
    }
	
	// MARK: - SafaArea
	fileprivate lazy var safeArea: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.carbon
		return view
	}()

	// subviews should add to this 'contentView'
	public final var contentView: UIView {
		return self.safeArea
	}
	
	// MARK: - topWood、ChessBoard、bottomWood
	fileprivate lazy var topWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
	fileprivate lazy var chessBoard: UIImageView = UIImageView()
	fileprivate lazy var bottomWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
	
	// MARK: - progressLayer
	internal var progressLayer: CAShapeLayer?
	
	// MARK: - Side、Nickname、Buttons
	internal lazy var topSide: UIImageView = UIImageView()
	internal lazy var topNickname: UILabel = UILabel()
	internal lazy var bottomSide: UIImageView = UIImageView()
	internal lazy var bottomNickname: UILabel = UILabel()
	
	// MARK: - ChessBoard & AI
	public lazy var AI: Luna = Luna()
	
	public lazy var chessBoardController: ChessBoardController = ChessBoardController(board: self.chessBoard.layer, AI: self.AI)
}

// MARK: - UI Layout
extension ChessVC {
	
	private func layoutContentView() {
		self.view.addSubview(self.safeArea)
		self.safeArea.snp.makeConstraints {
			$0.top.equalTo(self.view.layout.top)
			$0.left.equalTo(self.view.layout.left)
			$0.bottom.equalTo(self.view.layout.bottom)
			$0.right.equalTo(self.view.layout.right)
		}
	}
	
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
	
	private func layoutFlashLayer() {
		let layers = FlashLayerController.layer
		self.progressLayer = layers.progressLayer
		
		let container = UIView()
		container.backgroundColor = UIColor.clear
		container.layer.addSublayer(layers.backgroundLayer)
		
		self.chessBoard.addSubview(container)
		container.snp.makeConstraints {
			$0.center.equalTo(self.chessBoard.snp.center)
			$0.size.equalTo(layers.backgroundLayer.bounds.size)
		}
	}
	
	public final func layoutTopAndBottom(target: Any, attributes: [(title: String, action: Selector)]) {
		func layoutSubviews(toItem: UIView, side: UIImageView, nickname: UILabel, target: Any, attributes: [(title: String, action: Selector)]?) {
			guard let attributes = attributes else { return }
			
			let layout = LayoutPartner.ChessVC()
			let boardmargin = LayoutPartner.ChessBoard().boardmargin
			
			self.contentView.addSubview(side)
			side.snp.makeConstraints {
				$0.centerY.equalTo(toItem.snp.centerY)
				$0.left.equalTo(self.contentView.snp.left).offset(boardmargin)
				$0.size.equalTo(layout.sideSize)
			}
			
			nickname.textColor = UIColor.lightYellow
			nickname.font = UIFont.kaitiFont(ofSize: layout.nicknameFontSize)
			self.contentView.addSubview(nickname)
			nickname.snp.makeConstraints {
				$0.top.equalTo(side.snp.bottom)
				$0.centerX.equalTo(side.snp.centerX)
			}
			
			var frontView: UIView = side
			for attribute in attributes {
				let button = UIButton.gold
				button.titleLabel?.font = UIFont.kaitiFont(ofSize: layout.buttonTitleFontSize)
				button.layer.cornerRadius = layout.buttonCordins
				button.addTarget(target, action: attribute.action, for: .touchUpInside)
				button.setTitle(attribute.title, for: .normal)
				
				self.contentView.addSubview(button)
				button.snp.makeConstraints({
					$0.centerY.equalTo(toItem.snp.centerY)
					$0.left.equalTo(frontView.snp.right).offset(boardmargin)
					$0.size.equalTo(layout.buttonSize)
				})
				
				frontView = button
			}
		}
		
		layoutSubviews(toItem: self.topWood, side: self.topSide, nickname: self.topNickname, target: target, attributes: attributes[0...2])
		layoutSubviews(toItem: self.bottomWood, side: self.bottomSide, nickname: self.bottomNickname, target: target, attributes: attributes[3...5])
	}
	
}
