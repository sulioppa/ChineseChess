//
//  ChessBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class ChessBoardController: NSObject {
	
	// MARK: - Private Properties
	private var AI: Luna!
	
	private var board: CALayer!
	private var chess: [GridPoint: CALayer] = [:]
	private var move: (from: CALayer?, to: CALayer?) = (nil, nil)
	private var targets: [CALayer] = []
	
	// MARK: - init
	private override init() {
		super.init()
	}
	
	convenience init(board: CALayer, AI: Luna) {
		self.init()
		self.board = board
		self.AI = AI
	}
	
	// MARK: - reverse & opposite
	public var reverse: Bool = false {
		didSet {
			self.refreshBoard()
		}
	}
	
	public var opposite: Bool = false {
		didSet {
			self.refreshBoard()
		}
	}
}

// MARK: - Chess Operation
extension ChessBoardController {
	
	public func refreshBoard() {
		self.clearBoard()
		for (var index, location) in self.AI.chess().enumerated() {
			if location.uint8Value > 0 {
				index += 16
				if let image = ResourcesProvider.shared.chess(index: index) {
					let grid = GridPoint(location: location.uint8Value, isRervse: self.reverse)
					self.chess[grid]?.removeFromSuperlayer()
					self.chess[grid] = self.drawChess(at: grid, isOppositie: self.isOpposite(chess: index), image: image)
				}
			}
		}
	}
	
	private func clearBoard() {
		// clear chess
		for (_, item) in self.chess.enumerated() {
			item.value.removeFromSuperlayer()
		}
		self.chess.removeAll()
		
		// clear move
		self.move.from?.removeFromSuperlayer()
		self.move.to?.removeFromSuperlayer()
		self.move.from = nil
		self.move.to = nil
		
		// clear targets
		for target in self.targets {
			target.removeFromSuperlayer()
		}
		self.targets.removeAll()
	}
	
	private func isOpposite(chess: Int) -> Bool {
		guard self.opposite else { return false }
		return self.reverse ? chess < 32 : chess > 31
	}
	
}

// MARK: - Private Internal Class
extension ChessBoardController {
	
	public struct GridPoint: Hashable {
		public var x: Int = 0
		public var y: Int = 0
		
		init(location: UInt8, isRervse: Bool) {
			self.x = Int(location >> 4) - 3
			self.y = Int(location & 0xf) - 3
			if isRervse {
				self.x = 9 - self.x
				self.y = 8 - self.y
			}
		}
		
		public var description: String {
			return "(\(x), \(y))"
		}
		
		// MARK: - Hashable
		var hashValue: Int {
			return (x << 4) + y
		}
		
		static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
			return lhs.x == rhs.x && lhs.y == rhs.y
		}
	}
	
	private struct MetaPoint {
		private static let layout = LayoutPartner.ChessBoard()
		
		public static func metaPoint(point: GridPoint) -> CGRect {
			return CGRect(
				x: CGFloat(point.y) * layout.gridSize + layout.xOffset,
				y: CGFloat(point.x) * layout.gridSize + layout.yOffset,
				width: layout.chessSize,
				height: layout.chessSize
			)
		}
	}
	
}

// MARK: - Chess Draw
extension ChessBoardController {
	
	public func drawChess(at point: GridPoint, isOppositie: Bool, image: UIImage, below sibling: CALayer? = nil) -> CALayer {
		let layer = CALayer()
		layer.contents = image.cgImage
		layer.frame = MetaPoint.metaPoint(point: point)
		if isOppositie {
			layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
		}
		
		if sibling == nil {
			self.board.addSublayer(layer)
		} else {
			self.board.insertSublayer(layer, below: sibling)
		}
		return layer
	}
	
}
