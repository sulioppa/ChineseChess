//
//  ChessBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MARK: - ChessBoardController
class ChessBoardController: NSObject {
	
	public final var AI: Luna!
	
	// MARK: - Private Properties
	private var board: UIView!
	private var chess: [GridPoint: CALayer] = [:]
	private var lastMove: (from: CALayer?, to: CALayer?) = (nil, nil)
	
	// MARK: - init
	private override init() {
		super.init()
	}
	
	public init(board: UIView, AI: Luna, isUserInteractionEnabled: Bool) {
		super.init()
		self.board = board
		self.AI = AI
		
		if isUserInteractionEnabled {
			self.board.addTapTarget(self, action: #selector(didTapInBoard(gesture:)))
		}
	}
	
	// MARK: - Tap Tap Tap~
	@objc private func didTapInBoard(gesture: UITapGestureRecognizer) {
		let point = MetaPoint.metaPoint(point: gesture.location(in: self.board))
		if point.isLegal {
			self.didTapInBoard(at: point)
		}
	}
	
	public func didTapInBoard(at point: GridPoint) {
		fatalError("【Error】：\(#function) should be override at child class.")
	}
	
	// MARK: - reverse & opposite
	public final var reverse: Bool = false {
		didSet {
			self.refreshBoard()
		}
	}
	
	public final var opposite: Bool = false {
		didSet {
			self.refreshBoard()
		}
	}
}

// MARK: - Public Chess Operation
extension ChessBoardController {

	public final func refreshBoard() {
		self.clearBoard()
		// draw chesses
		for (index, location) in self.AI.chesses.enumerated() {
			self.drawChess(chess: index + 16, location: location.uint8Value)
		}
		// draw last move
		self.refreshLastMove(with: self.AI.lastMove)
	}
	
	public final func clearBoard() {
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
		assert(15 < chess && chess < 48 , "\(#function) 's chess must be more than 15 and less than 48")
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

// MARK: - Public Chess move and recover
extension ChessBoardController {
	
	public final func moveChess(with preparation: (() -> Void)? = nil, from: GridPoint, to: GridPoint, completion: (() -> Void)? = nil) {
		guard let aChess = self.chess[from] else { return }
		
		preparation?()
		CATransaction.begin()
		CATransaction.setAnimationDuration(Macro.Time.chessMoveLastTime)
		
		// rise up the chess, make it on the top of its super layer
		aChess.removeFromSuperlayer()
		self.board.layer.addSublayer(aChess)
		
		// a chess to be ate
		let ateChess = self.chess[to]
		
		// move the chess
		self.chess.removeValue(forKey: from)
		self.chess[to] = aChess
		aChess.position = MetaPoint.metaPosition(point: to)
		
		// finally, remove the ate chess
		CATransaction.setCompletionBlock {
			ateChess?.removeFromSuperlayer()
			completion?()
		}
		CATransaction.commit()
	}
	
	public final func recoverChess(with preparation: (() -> Void)? = nil, from: GridPoint, to: GridPoint, recover: Int, completion: (() -> Void)? = nil) {
		assert(self.chess[to] == nil, "【Error】：\(#function) 's GridPoint to must have no chess.")
		guard let aChess = self.chess[from] else { return }
		
		preparation?()
		CATransaction.begin()
		CATransaction.setAnimationDuration(Macro.Time.chessMoveLastTime)
		
		// rise up the chess, make it on the top of its super layer
		aChess.removeFromSuperlayer()
		self.board.layer.addSublayer(aChess)
		
		// update the chess
		self.chess.removeValue(forKey: from)
		self.chess[to] = aChess
		
		// recover the ate chess
		if recover > 0 {
			if let image = ResourcesProvider.shared.chess(index: recover) {
				let opposite = self.opposite ? (self.reverse ? recover < 32 : recover > 31) : false
				self.chess[from] = self.drawChess(at: from, isOppositie: opposite, image: image, below: aChess)
			}
		}
		
		// move the chess
		aChess.position = MetaPoint.metaPosition(point: to)
		
		CATransaction.setCompletionBlock {
			completion?()
		}
		CATransaction.commit()
	}

}

// MARK: - Public Struct GridPoint
extension ChessBoardController {
	
	public struct GridPoint: Hashable {
		public var x: Int = 0
		public var y: Int = 0
		
		public init(location: UInt8, isReverse: Bool) {
			self.x = Int(location >> 4) - 3
			self.y = Int(location & 0xf) - 3
			if isReverse {
				self.reverse()
			}
		}
		
		public init(x: Int, y: Int) {
			self.x = x
			self.y = y
		}
		
		public mutating func reverse() {
			self.x = 9 - self.x
			self.y = 8 - self.y
		}
		
		public var location: UInt8 {
			return UInt8(((self.x + 3) << 4) + self.y + 3)
		}
		
		public var isLegal: Bool {
			return 0 <= self.x && self.x <= 9 && 0 <= self.y && self.y <= 8
		}
		
		public var description: String {
			return "GridPoint: (row: \(x), column: \(y))"
		}
		
		// Conform Hashable
		public var hashValue: Int {
			return (x << 4) + y
		}
		
		public static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
			return lhs.x == rhs.x && lhs.y == rhs.y
		}
	}
	
}

// MARK: - Private MetaPoint & Draw a chess
extension ChessBoardController {

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
			
			let xOffset = point.x - layout.basePoint.x - CGFloat(column) * layout.gridSize
			let yOffset = point.y - layout.basePoint.y - CGFloat(row) * layout.gridSize
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
