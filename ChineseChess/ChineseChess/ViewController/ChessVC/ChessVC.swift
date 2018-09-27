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
		
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserPreference), name: UIApplication.willResignActiveNotification, object: nil)
    }
	
	// MARK: - Update UserPreference
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.updateUserPreference()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		self.updateUserPreference()
	}
	
	@objc public func updateUserPreference() {
		fatalError("\(#function) should be override by subclass")
	}
	
	// MARK: - SafaArea
	private lazy var safeArea: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}()
	
	// MARK: - ChessBoard
	private lazy var chessBoard: UIImageView = UIImageView()
	
	// MARK: - progressLayer
	private var progressLayer: CAShapeLayer?
	
	// MARK: - Side、Nickname、Buttons
	private lazy var topSide: UIImageView = UIImageView()
	private lazy var topNickname: UILabel = UILabel()
	private lazy var bottomSide: UIImageView = UIImageView()
	private lazy var bottomNickname: UILabel = UILabel()
	
	// MARK: - AI
	private lazy var luna: Luna = Luna()
	
	// MARK: - Status Bar
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .none
	}
	
	override var prefersStatusBarHidden: Bool {
		return !LayoutPartner.hasSafeArea
	}
	
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
		
		let topWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
		self.view.insertSubview(topWood, at: 0)
		topWood.snp.makeConstraints {
			$0.top.equalTo(self.view)
			$0.left.equalTo(self.view)
			$0.bottom.equalTo(self.chessBoard.snp.top)
			$0.right.equalTo(self.view)
		}
		
		let bottomWood: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "wood"))
		self.view.insertSubview(bottomWood, at: 0)
		bottomWood.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0.0, 0.0, 1.0)
		bottomWood.snp.makeConstraints {
			$0.top.equalTo(self.chessBoard.snp.bottom)
			$0.left.equalTo(self.view)
			$0.bottom.equalTo(self.view)
			$0.right.equalTo(self.view)
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
		
		func container(isTop: Bool) -> UIView {
			let container = UIView()
			container.backgroundColor = UIColor.clear
			self.contentView.addSubview(container)
			
			container.snp.makeConstraints {
				if isTop {
					$0.top.equalTo(self.contentView)
					$0.bottom.equalTo(self.chessBoard.snp.top)
				} else {
					$0.top.equalTo(self.chessBoard.snp.bottom)
					$0.bottom.equalTo(self.contentView)
				}
				$0.left.equalTo(self.contentView)
				$0.right.equalTo(self.contentView)
			}
			
			return container
		}
		
		layoutSubviews(toItem: container(isTop: true), side: self.topSide, nickname: self.topNickname, target: target, attributes: attributes[0...2])
		layoutSubviews(toItem: container(isTop: false), side: self.bottomSide, nickname: self.bottomNickname, target: target, attributes: attributes[3...5])
	}
	
}

// MARK: - Attributes visible to child class
extension ChessVC {
	
	// subviews should add to this 'contentView'
	public final var contentView: UIView {
		return self.safeArea
	}
	
	public final var board: UIView {
		return self.chessBoard
	}
	
	public final var AI: Luna {
		return self.luna
	}
	
}

// MARK: - Top and bottom Side Operation.
extension ChessVC {
	
	public enum SideState: Int {
		case AI = -1
		case red
		case black
		
		var image: UIImage? {
			switch self {
			case .AI:
				return ResourcesProvider.shared.image(named: "AI")
			case .red:
				return ResourcesProvider.shared.image(named: "帥")
			case .black:
				return ResourcesProvider.shared.image(named: "將")
			}
		}
		
		public static func side(level: UserPreference.Level, isRed: Bool) -> SideState {
			if level.isPlayer {
				return isRed ? .red : .black
			} else {
				return .AI
			}
		}
		
	}
	
	public final func setSideState(top: SideState, bottom: SideState) {
		self.topSide.image = top.image
		self.bottomSide.image = bottom.image
	}
	
	public final func setNickname(top: String, bottom: String) {
		self.topNickname.text = top
		self.bottomNickname.text = bottom
	}
	
}

// MAKR: - Think Animation
extension ChessVC {
	
	public final func setFlashProgress(progress: Float) {
		guard progress >= 0.0 && progress <= 1.0 else { return }
		self.progressLayer?.path = FlashLayerController.rect(progress: progress)
	}
	
}
