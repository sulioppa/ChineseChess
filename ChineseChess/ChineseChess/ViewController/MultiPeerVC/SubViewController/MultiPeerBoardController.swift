//
//  MultiPeerBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/24.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

protocol MultiPeerBoardControllerDelegate: NSObjectProtocol {
	
	func multiPeerBoardControllerWillEndTheGame()
	
	func multiPeerBoardControllerDidEndTheGame(isNormal: Bool)
	
	func multiPeerBoardController(didMove oneStep: LunaMove)
	
	var canRequest: Bool { get }
	
}

class MultiPeerBoardController: ChessBoardController {
	
	// the GridPoint current player selected.
	private var choice: (grid: GridPoint, layer: CALayer?) = (GridPoint.none, nil)
	
	// the GridPoints of the selected chess can go.
	private var legalMoves: [GridPoint: CALayer] = [:]
	
	// the lastest move.
	private var lastMove: (from: CALayer?, to: CALayer?) = (nil, nil)
	
	// isRegreting reveals the game is in progress of regreting.
	public var isRegreting: Bool = false
	
	public weak var delegate: MultiPeerBoardControllerDelegate? = nil
	
	// MARK: - Handle Tap
	public override func didTapInBoard(at grid: ChessBoardController.GridPoint, atPoint: CGPoint) {
		let canRespond = self.canRespond
		if !canRespond.can {
			TextAlertView.show(in: self.contentView, text: canRespond.error)
			return
		}
		
		if self.choice.grid.isLegal {
			// has chosen one.
			if grid == self.choice.grid {
				WavHandler.playVoice(state: .select)
				return
			}
			
			// not the same grid, try to make another choice.
			if self.makeChoice(location: grid.location(self.reverse)) {
				return
			}
			
			// make the move
			if self.legalMoves[grid] != nil {
				self.makeMove(to: grid)
			}
		} else {
			// not chose. try to make a choice.
			let _ = self.makeChoice(location: grid.location(self.reverse))
		}
	}
	
	// MARK: - Board Operation
	public override func refreshBoard() {
		super.refreshBoard()
		self.refreshLastMove(with: self.AI.lastMove?.move)
	}
	
	public override func clearBoard() {
		super.clearBoard()
		self.clearLastMove()
		self.clearChoice()
		self.clearLegalMoves()
	}
	
}

// MARK: - Public
extension MultiPeerBoardController {
	
	public final func createGame(with history: String) {
		self.AI.initBoard(withFile: history)
		self.reverse = !UserPreference.shared.multiPeer.red
		
		WavHandler.playVoice(state: .normal)
		BladeAlertView.show(in: self.contentView, text: "对局开始")
	}
	
	public final func complexRegret() {
		self.isRegreting = true
		self.regretOneStep(hasNext: true)
	}
	
	public final func moveOneStep(move: LunaMove) {
		let state = self.AI.moveChess(withMove: move)
		WavHandler.playVoice(state: state)
		
		let from = GridPoint(location: move.from, isReverse: self.reverse)
		let to = GridPoint(location: move.to, isReverse: self.reverse)
		
		self.moveChess(from: from, to: to)
		self.refreshLastMove(with: self.AI.lastMove?.move)
		
		if !self.AI.state.isNormalState {
			self.delegate?.multiPeerBoardControllerWillEndTheGame()
			BladeAlertView.show(in: self.contentView, text: self.AI.state.description) {
				self.delegate?.multiPeerBoardControllerDidEndTheGame(isNormal: true)
			}
		}
		
		NotificationCenter.default.post(name: Macro.NotificationName.didUpdateOneStep, object: nil, userInfo: [
			"item": self.AI.lastMove!.item,
			"result": self.AI.state.result
			])
	}
	
}

// MARK: - Private - Support Handling Tap
extension MultiPeerBoardController {
	
	private var canRespond: (can: Bool, error: String?) {
		guard self.AI.state.isNormalState && !self.isRegreting else { return (false, nil) }
		
		if self.AI.state == .turnRedSide && !UserPreference.shared.multiPeer.red {
			return (false, "对方走")
		} else if self.AI.state == .turnBlackSide && UserPreference.shared.multiPeer.red {
			return (false, "对方走")
		} else if !self.canRequest {
			return (false, nil)
		} else {
			return (true, nil)
		}
	}
	
	private var canRequest: Bool {
		return self.delegate?.canRequest ?? false
	}
	
	private func makeChoice(location: LunaLocation) -> Bool {
		if self.AI.isAnotherChoice(withLocation: location) {
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
		let state = self.AI.moveChess(withMove: move)
		WavHandler.playVoice(state: state)
		
		self.delegate?.multiPeerBoardController(didMove: move)
		
		self.moveChess(from: self.choice.grid, to: to)
		self.refreshLastMove(with: self.AI.lastMove?.move)
		self.clearChoice()
		
		if !self.AI.state.isNormalState {
			self.delegate?.multiPeerBoardControllerWillEndTheGame()
			BladeAlertView.show(in: self.contentView, text: self.AI.state.description) {
				self.delegate?.multiPeerBoardControllerDidEndTheGame(isNormal: true)
			}
		}
		
		NotificationCenter.default.post(name: Macro.NotificationName.didUpdateOneStep, object: nil, userInfo: [
			"item": self.AI.lastMove!.item,
			"result": self.AI.state.result
			])
	}
	
	// choice
	private func refreshChoice(with location: LunaLocation) {
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
	private func refreshLegalMoves(with choice: LunaLocation) {
		self.clearLegalMoves()
		// draw ruby
		for (_, location) in self.AI.legalMoves(withLocation: choice).enumerated() {
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
	
}

// MARK: - Chess move & recover & Regret
extension MultiPeerBoardController {
	
	private func moveChess(from: GridPoint, to: GridPoint) {
		self.moveChess(with: nil, from: from, to: to, completion: {})
	}
	
	private func recoverChess(from: GridPoint, to: GridPoint, recover: Int, hasNext: Bool) {
		self.recoverChess(with: nil, from: from, to: to, recover: recover, completion: {
			if hasNext {
				self.regretOneStep(hasNext: false)
			} else {
				self.isRegreting = false
			}
		})
	}
	
	private func regretOneStep(hasNext: Bool) {
		var move: LunaMove = 0
		let ate = Int(self.AI.regret(withMove: &move))
		
		if move > 0 {
			self.recoverChess(from: GridPoint(location: move.to, isReverse: self.reverse), to: GridPoint(location: move.from, isReverse: self.reverse), recover: ate, hasNext: hasNext)
			
			self.clearChoice()
			self.clearLegalMoves()
			self.refreshLastMove(with: self.AI.lastMove?.move)
			WavHandler.playVoice(state: .normal)
		}
	}
	
}
