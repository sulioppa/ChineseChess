//
//  EditBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/16.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class EditBoardController: ChessBoardController {

	// the GridPoint user selected.
	private var choice: (grid: GridPoint, layer: CALayer?) = (GridPoint.none, nil)
	
	// MARK: - Handle Tap
	public override func didTapInBoard(at grid: ChessBoardController.GridPoint, atPoint: CGPoint) {
		if self.choice.grid.isLegal {
			if grid == self.choice.grid {
				self.removeChess(at: grid)
				return
			}
			
			self.makeMove(to: grid)
		} else {
			if self.AI.chess(atLocation: grid.location(self.reverse)) == 0 {
				self.drawChoice(point: grid)
				self.showCanPutChesses(at: atPoint, location: grid.location(self.reverse))
				return
			}
			
			self.makeChoice(point: grid)
		}
	}
	
	// MARK: - Board Operation
	public override func clearBoard() {
		super.clearBoard()
		self.clearChoice()
	}
	
}

// MARK: - Private - Support Handling Tap
extension EditBoardController: EditChessesViewDelegate {

	private func removeChess(at grid: GridPoint) {
		defer {
			self.resetChoice()
		}
		
		guard self.AI.erase(withLocation: grid.location(self.reverse)) == .normalEat else { return }
		
		WavHandler.playVoice(state: .eat)
		self.removeChess(at: grid.location(self.reverse))
	}
	
	private func makeMove(to grid: GridPoint) {
		let chess = self.AI.chess(atLocation: self.choice.grid.location(self.reverse))
		let eat = self.AI.chess(atLocation: grid.location(self.reverse))
		let result = self.AI.move(withMove: GridPoint.move(from: self.choice.grid, to: grid, isReverse: self.reverse))
		
		switch result {
		case .normalPut, .normalEat:
			WavHandler.playVoice(state: result == .normalEat ? .eat : .normal)
			self.removeChess(at: self.choice.grid.location(self.reverse))
			self.drawChess(chess: Int(chess), location: grid.location(self.reverse))
			self.resetChoice()
			
		case .wrongPut, .wrongEat:
			if eat == 0 {
				self.resetChoice()
				self.drawChoice(point: grid)
				TextAlertView.show(in: self.contentView, text: result.description(name: chess.name))
			} else {
				self.makeChoice(point: grid)
			}
            
        @unknown default:
            break
        }
	}
	
	private func makeChoice(point: GridPoint) {
		WavHandler.playVoice(state: .select)
		self.choice.grid = point
		self.drawChoice(point: point)
	}
	
	private func resetChoice() {
		self.clearChoice()
		self.choice.grid.clear()
	}
	
	private func drawChoice(point: GridPoint) {
		self.choice.layer?.removeFromSuperlayer()
		self.choice.layer = self.drawSquare(isRed: true, grid: point)
	}
	
	private func clearChoice() {
		self.choice.layer?.removeFromSuperlayer()
	}
	
	private func showCanPutChesses(at point: CGPoint, location: LunaLocation) {
		let chesses: [Int] = self.AI.putChesses.map ({ return $0.intValue })
		guard chesses.count > 0 else { return }
		
		EditChessesView(chesses: chesses, delegate: self, location: location).show(in: self.contentView, relatedview: self.board, point: point)
	}
	
	func editChessesView(didSelectChessWith index: Int, location: LunaLocation) {
		guard index > 0 else {
			self.clearChoice()
			return
		}
		
		let result = self.AI.put(withChess: LunaChess(index), at: location)
		guard result == .normalPut else {
			TextAlertView.show(in: self.contentView, text: result.description(name: LunaChess(index).name))
			return
		}
		
		WavHandler.playVoice(state: .normal)
		self.drawChess(chess: index, location: location)
		self.clearChoice()
	}
	
}
