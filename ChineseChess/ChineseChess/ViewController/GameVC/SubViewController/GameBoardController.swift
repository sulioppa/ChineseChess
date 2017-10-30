//
//  GameBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/28.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameBoardController: ChessBoardController {
	
	// the GridPoint current player selected.
	private var choice: (grid: GridPoint, layer: CALayer?) = (GridPoint.none, nil)
	
	// the GridPoints of the selected chess can go.
	private var legalMoves: [GridPoint: CALayer] = [:]
	
	// the lastest move.
	private var lastMove: (from: CALayer?, to: CALayer?) = (nil, nil)
	
	// isMoving reveals the chess is moving or not.
	private var isMoving: Bool = false
	
	// taskQueue, to avoid data mess. Reverse, opposite and chess move should be serially executed.
	private let taskQueue: DispatchQueue = DispatchQueue(label: "com.sulioppa.game.taskQueue")
	private let taskSignal: DispatchSemaphore = DispatchSemaphore(value: 1)
	
	// MARK: - Handle Tap
	public override func didTapInBoard(at point: ChessBoardController.GridPoint) {
		guard self.canRespond else { return }
		
		if self.choice.grid.isLegal {
			// has chosen one.
			if point == self.choice.grid {
				WavHandler.playVoice(state: .select)
				return
			}
			
			// not the same grid, try to make another choice.
			if self.makeChoice(location: point.location(self.reverse)) {
				return
			}
			
			// make the move
			if self.legalMoves[point] != nil {
				self.makeMove(to: point)
			}
		} else {
			// not chose. try to make a choice.
			let _ = self.makeChoice(location: point.location(self.reverse))
		}
	}
	
	// MARK: - Board Operation
	public override func refreshBoard() {
		super.refreshBoard()
		self.refreshLastMove(with: self.AI.lastMove)
	}
	
	public override func clearBoard() {
		super.clearBoard()
		self.clearLastMove()
		self.clearChoice()
		self.clearLegalMoves()
	}
	
}

// MARK: - Support Handling Tap
extension GameBoardController {
	
	private var canRespond: Bool {
		if self.isMoving || self.AI.isThinking {
			return false
		} else {
			return (UserPreference.shared.game.red && self.AI.state == .redPlayer)
				|| (UserPreference.shared.game.black && self.AI.state == .blackPlayer)
		}
	}
	
	private func makeChoice(location: Luna_Location) -> Bool {
		if self.AI.isAnotherChoice(with: location) {
			WavHandler.playVoice(state: .select)
			self.refreshChoice(with: location)
			self.refreshLegalMoves(with: location)
			return true
		}
		return false
	}
	
	private func makeMove(to: GridPoint) {
		self.clearLegalMoves()
		let move = GridPoint.move(from: self.choice.grid, to: to, isReverse: self.reverse)
		let state = self.AI.moveChess(with: move)
		WavHandler.playVoice(state: state)
		
		self.refreshLastMove(with: self.AI.lastMove)
		self.moveChess(from: self.choice.grid, to: to)
		self.clearChoice()
	}
	
	// choice
	private func refreshChoice(with location: Luna_Location) {
		self.clearChoice()
		self.choice.grid.reset(location: location, isReverse: self.reverse)
		self.choice.layer = self.drawSquare(isRed: true, grid: self.choice.grid)
	}
	
	private func clearChoice() {
		self.choice.layer?.removeFromSuperlayer()
		self.choice.layer = nil
		self.choice.grid.clear()
	}
	
	// legal moves
	private func refreshLegalMoves(with choice: Luna_Location) {
		self.clearLegalMoves()
		// draw ruby
		for (_, location) in self.AI.legalMoves(with: choice).enumerated() {
			let result = self.drawRuby(location: location.uint8Value)
			self.legalMoves[result.grid] = result.ruby
		}
	}
	
	private func clearLegalMoves() {
		for (_, item) in self.legalMoves.enumerated() {
			item.value.removeFromSuperlayer()
		}
		self.legalMoves.removeAll()
	}
	
	// last move
	private func refreshLastMove(with move: Luna_Move) {
		self.clearLastMove()
		self.lastMove.from = self.drawSquare(isRed: false, location: Luna_Location(move >> 8))
		self.lastMove.to = self.drawSquare(isRed: false, location: Luna_Location(move & 0xff))
	}
	
	private func clearLastMove() {
		self.lastMove.from?.removeFromSuperlayer()
		self.lastMove.to?.removeFromSuperlayer()
		self.lastMove.from = nil
		self.lastMove.to = nil
	}
	
}

// MARK: - AsyncTask & Voice
extension GameBoardController {
	
	private func asyncTask(task: @escaping (@escaping () -> Void) -> Void) {
		self.taskQueue.async { [weak self] in
			self?.taskSignal.wait()
			DispatchQueue.main.async {
				task() {
					self?.taskSignal.signal()
				}
			}
		}
	}
	
}

// MARK: - Chess move and recover
extension GameBoardController {
	
	private func moveChess(from: GridPoint, to: GridPoint) {
		self.asyncTask { [weak self] (release) in
			self?.moveChess(with: {
				self?.isMoving = true
			}, from: from, to: to, completion: {
				self?.isMoving = false
				release()
			})
		}
	}
	
	private func recoverChess(from: GridPoint, to: GridPoint, recover: Int) {
		self.asyncTask { [weak self] (release) in
			self?.recoverChess(with: {
				self?.isMoving = true
			}, from: from, to: to, recover: recover, completion: {
				self?.isMoving = false
				release()
			})
		}
	}
	
}
