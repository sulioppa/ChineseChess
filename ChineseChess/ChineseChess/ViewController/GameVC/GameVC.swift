//
//  GameVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameVC: ChessVC {

	private lazy var chessBoardController: ChessBoardController = ChessBoardController(board: self.board, AI: self.AI)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("新 局", #selector(newGame)),
			("设 置", #selector(settings)),
			("返 回", #selector(back)),
			("悔 棋", #selector(regretOneStep)),
			("提 示", #selector(teachMe)),
			("菜 单", #selector(showMenu)),
			])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.refreshUI()
	}
	
	private func refreshUI() {
		self.setSideState(top: .black, bottom: .red)
		self.setNickname(top: "棋手", bottom: "棋手")
		self.chessBoardController.reverse = UserPreference.shared.game.reverse
		self.chessBoardController.opposite = UserPreference.shared.game.opposite
	}
	
}

// MARK: - Action.
extension GameVC {
	
	@objc private func newGame() {
		self.chessBoardController.reverse = UserPreference.shared.game.reverse.reverse()
	}
	
	@objc private func settings() {
		self.chessBoardController.opposite = UserPreference.shared.game.opposite.reverse()
	}
	
	@objc private func back() {
		WavHandler.playWav()
		self.dismiss()
	}
	
	@objc private func regretOneStep() {
		self.chessBoardController.clearBoard()
	}
	
	@objc private func teachMe() {
		self.setFlashProgress(progress: Float.random)
	}
	
	@objc private func showMenu() {
		
	}
	
}
