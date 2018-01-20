//
//  HistoryBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/20.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class HistoryBoardController: ChessBoardController {

	// the lastest move.
	private var lastMove: (from: CALayer?, to: CALayer?) = (nil, nil)
	
	// isMoving reveals the chess is moving or not.
	private var isMoving: Bool = false
	
	public override func refreshBoard() {
		super.refreshBoard()
		self.refreshLastMove(with: self.AI.currentRecord?.move)
	}
	
	public override func clearBoard() {
		super.clearBoard()
		self.clearLastMove()
	}
	
}

// MARK: - Public
extension HistoryBoardController {
	
	public func refreshBoard(at index: Int) {
		UserPreference.shared.history.index = index
		self.AI.moveIndex(at: index)
		self.refreshBoard()
	}
	
	public func moveForward() {
		guard !self.isMoving else { return }
		
		guard let record = self.AI.moveForward() else {
			TextAlertView.show(in: self.contentView, text: UserPreference.shared.history.result)
			return
		}
		
		self.isMoving = true
		UserPreference.shared.history.index += 1
		self.refreshLastMove(with: record.move)
		self.makeMove(move: record.move, hasEat: record.eat > 0)
	}
	
	public func backForward() {
		guard !self.isMoving else { return }
		
		guard let record = self.AI.backForward() else {
			WavHandler.playButtonWav()
			return
		}
		
		self.isMoving = true
		UserPreference.shared.history.index -= 1
		self.refreshLastMove(with: self.AI.currentRecord?.move)
		self.recoverMove(move: record.move, eat: record.eat)
	}
	
}

// MARK: - Private
extension HistoryBoardController {
	
	// last move
	private func refreshLastMove(with move: LunaMove?) {
		self.clearLastMove()
		if let move = move, move != 0 {
			self.lastMove.from = self.drawSquare(isRed: false, location: move.from)
			self.lastMove.to = self.drawSquare(isRed: false, location: move.to)
		}
	}
	
	private func clearLastMove() {
		self.lastMove.from?.removeFromSuperlayer()
		self.lastMove.to?.removeFromSuperlayer()
		self.lastMove.from = nil
		self.lastMove.to = nil
	}
	
	// move and recover
	private func makeMove(move: LunaMove, hasEat: Bool) {
		WavHandler.playVoice(state: hasEat ? .eat : .normal)
		
		let from = GridPoint(location: move.from, isReverse: self.reverse)
		let to = GridPoint(location: move.to, isReverse: self.reverse)
		self.moveChess(with: nil, from: from, to: to) {
			self.isMoving = false
		}
	}
	
	private func recoverMove(move: LunaMove, eat: LunaChess) {
		WavHandler.playVoice(state: .normal)
		
		let from = GridPoint(location: move.from, isReverse: self.reverse)
		let to = GridPoint(location: move.to, isReverse: self.reverse)
		self.recoverChess(with: nil, from: to, to: from, recover: Int(eat)) {
			self.isMoving = false
		}
	}
	
}


