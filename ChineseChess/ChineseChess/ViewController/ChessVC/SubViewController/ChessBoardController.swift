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
	
	private var board: UIView!
	private var chess: [GridPoint: CALayer] = [:]
	private var lastMove: (from: CALayer?, to: CALayer?) = (nil, nil)
	
	// MARK: - init
	private override init() {
		super.init()
	}
	
	convenience init(board: UIView, AI: Luna) {
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
		// draw chesses
		for (index, location) in self.AI.chesses().enumerated() {
			self.drawChess(chess: index + 16, location: location.uint8Value)
		}
		// draw last move
		self.refreshLastMove(with: self.AI.lastMove())
	}
	
	public func clearBoard() {
		// clear chesses
		for (_, item) in self.chess.enumerated() {
			item.value.removeFromSuperlayer()
		}
		self.chess.removeAll()
		// clear last move
		self.clearLastMove()
	}
	
	public final func refreshLastMove(with move: UInt16) {
		self.clearLastMove()
		self.lastMove.from = self.drawSquare(isRed: false, location: UInt8(move >> 8))
		self.lastMove.to = self.drawSquare(isRed: false, location: UInt8(move & 0xff))
	}
	
	public final func clearLastMove() {
		self.lastMove.from?.removeFromSuperlayer()
		self.lastMove.to?.removeFromSuperlayer()
		self.lastMove.from = nil
		self.lastMove.to = nil
	}
	
}

// MARK: - Public Draw a chess at grid or location
extension ChessBoardController {
	
	public final func drawChess(chess: Int, location: UInt8, below sibling: CALayer? = nil) {
		guard location > 0 else { return }
		guard let image = ResourcesProvider.shared.chess(index: chess) else { return }
		
		let grid = GridPoint(location: location, isReverse: self.reverse)
		let opposite = self.opposite ? (self.reverse ? chess < 32 : chess > 31) : false
		self.chess[grid]?.removeFromSuperlayer()
		self.chess[grid] = self.drawChess(at: grid, isOppositie: opposite, image: image, below: sibling)
	}
	
	public final func drawRuby(location: UInt8) -> (grid: GridPoint?, ruby: CALayer?) {
		guard let image = ResourcesProvider.shared.chess(index: 1) else { return (nil, nil) }
		
		let grid = GridPoint(location: location, isReverse: self.reverse)
		return (grid, self.drawChess(at: grid, isOppositie: false, image: image))
	}
	
	public final func drawSquare(isRed: Bool, location: UInt8) -> CALayer? {
		let grid = GridPoint(location: location, isReverse: self.reverse)
		return self.drawSquare(isRed: isRed, grid: grid)
	}
	
	public final func drawSquare(isRed: Bool, grid: GridPoint) -> CALayer? {
		guard let image = ResourcesProvider.shared.chess(index: isRed ? 3 : 2) else { return nil }
		return self.drawChess(at: grid, isOppositie: false, image: image)
	}
	
}

// MARK: - Internal Struct
extension ChessBoardController {
	
	public struct GridPoint: Hashable {
		public var x: Int = 0
		public var y: Int = 0
		
		init(location: UInt8, isReverse: Bool) {
			self.x = Int(location >> 4) - 3
			self.y = Int(location & 0xf) - 3
			if isReverse {
				self.reverse()
			}
		}
		
		public var location: UInt8 {
			return UInt8(((self.x + 3) << 4) + self.y + 3)
		}
		
		init(x: Int, y: Int) {
			self.x = x
			self.y = y
		}
		
		public mutating func reverse() {
			self.x = 9 - self.x
			self.y = 8 - self.y
		}
		
		public var description: String {
			return "GridPoint: (\(x), \(y))"
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
				x: CGFloat(point.y) * layout.gridSize + layout.basePoint.x - layout.chessSize / 2.0,
				y: CGFloat(point.x) * layout.gridSize + layout.basePoint.y - layout.chessSize / 2.0,
				width: layout.chessSize,
				height: layout.chessSize
			)
		}
		
		public static func metaPoint(point: CGPoint) -> GridPoint {
			var column = Int((point.x - layout.basePoint.x) / layout.gridSize)
			var row = Int((point.y - layout.basePoint.y) / layout.gridSize)
			
			let xOffset = point.x - CGFloat(column) * layout.gridSize
			let yOffset = point.y - CGFloat(row) * layout.gridSize
			let midOffset = layout.gridSize / 2.0
			
			if xOffset > midOffset {
				column += 1
			}
			if yOffset > midOffset {
				row += 1
			}
			return GridPoint(x: row, y: column)
		}
		
		// move's position
		public static func metaPosition(point: GridPoint) -> CGPoint {
			return CGPoint(
				x: CGFloat(point.y) * layout.gridSize + layout.basePoint.x,
				y: CGFloat(point.x) * layout.gridSize + layout.basePoint.y
			)
		}
	}
	
}

// MARK: - Private Draw a chess
extension ChessBoardController {

	private final func drawChess(at point: GridPoint, isOppositie: Bool, image: UIImage, below sibling: CALayer? = nil) -> CALayer {
		let layer = CALayer()
		layer.contents = image.cgImage
		layer.frame = MetaPoint.metaPoint(point: point)
		if isOppositie {
			layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
		}
		
		if sibling == nil {
			self.board.layer.addSublayer(layer)
		} else {
			self.board.layer.insertSublayer(layer, below: sibling)
		}
		return layer
	}
	
}
