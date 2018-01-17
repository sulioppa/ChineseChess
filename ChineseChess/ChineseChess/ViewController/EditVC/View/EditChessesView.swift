//
//  EditChessesView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/16.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

protocol EditChessesViewDelegate: NSObjectProtocol {
	func editChessesView(didSelectChessWith index: Int, location: LunaLocation)
}

class EditChessesView: UIView {

	private weak var delegate: EditChessesViewDelegate? = nil
	private var location: LunaLocation = 0
	
	private lazy var contentview: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0, alpha: 0.5)
		return view
	}()
	
	init(chesses: [Int], delegate: EditChessesViewDelegate, location: LunaLocation) {
		super.init(frame: CGRect.zero)
		self.backgroundColor = UIColor.clear
		
		self.delegate = delegate
		self.location = location
		self.addTapTarget(self, action: #selector(self.hide))
		
		let size = LayoutPartner.ChessBoard().chessSize
		self.contentview.frame = .zero
		self.contentview.layer.cornerRadius = size / 2.0
		self.addSubview(self.contentview)
		
		func layoutButton(tag: Int, point: CGPoint) {
			let button = UIButton()
			button.frame = CGRect(origin: point, size: CGSize(width: size, height: size))
			button.setBackgroundImage(ResourcesProvider.shared.chess(index: tag), for: .normal)
			button.tag = tag
			button.addTarget(self, action: #selector(self.didSelect(sender:)), for: .touchUpInside)
			self.contentview.addSubview(button)
		}
		
		assert(chesses.count > 0, "\(#function) 's chesses.count must be more than 0.")
		guard let max = chesses.max(), let min = chesses.min() else { return }
		
		let hasRed = min < 32
		let hasBlack = max > 31
		
		var redPoint: CGPoint = .zero
		var blackPoint: CGPoint = .zero
		
		if hasRed && hasBlack {
			redPoint = .zero
			blackPoint = CGPoint(x: 0, y: size)
		} else if hasRed {
			redPoint = .zero
		} else if hasBlack {
			blackPoint = .zero
		}
		
		for chess in chesses {
			if chess < 32 {
				layoutButton(tag: chess, point: redPoint)
				redPoint.x += size
			} else {
				layoutButton(tag: chess, point: blackPoint)
				blackPoint.x += size
			}
		}
		
		self.contentview.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.maximum(redPoint.x, blackPoint.x), height: CGFloat.maximum(redPoint.y, blackPoint.y) + size))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func show(in superview: UIView, relatedview: UIView, point: CGPoint) {
		self.moveContentViewRect(in: superview, relatedview: relatedview, point: point)
		self.frame = superview.bounds
		superview.addSubview(self)
	}
	
	private func moveContentViewRect(in superview: UIView, relatedview: UIView, point: CGPoint) {
		self.contentview.frame.origin = point
		
		if self.contentview.frame.maxY > relatedview.bounds.maxY {
			self.contentview.frame.origin.y = point.y - self.contentview.frame.size.height
		}
		
		if self.contentview.frame.maxX > relatedview.bounds.maxX {
			self.contentview.frame.origin.x = relatedview.bounds.maxX - self.contentview.frame.size.width
		}
		
		self.contentview.frame.origin = relatedview.convert(self.contentview.frame.origin, to: superview)
	}
	
	// MARK: - Action.
	@objc private func didSelect(sender: UIButton) {
		self.removeFromSuperview()
		self.delegate?.editChessesView(didSelectChessWith: sender.tag, location: self.location)
	}
	
	@objc private func hide() {
		self.removeFromSuperview()
		self.delegate?.editChessesView(didSelectChessWith: 0, location: 0)
	}

}
