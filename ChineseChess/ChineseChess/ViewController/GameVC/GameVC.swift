//
//  GameVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameVC: ChessVC {

	private lazy var chessBoardController: GameBoardController = GameBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: true)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("设 置", #selector(settings)),
			("提 示", #selector(teachMe)),
			("返 回", #selector(back)),
			("新 局", #selector(newGame)),
			("悔 棋", #selector(regretOneStep)),
			("菜 单", #selector(showMenu)),
			])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.refreshUI()
	}
	
	private func refreshUI() {
		self.setSideState(top: .AI, bottom: .red)
		self.setNickname(top: "棋手", bottom: "棋手")
		self.chessBoardController.reverse = UserPreference.shared.game.reverse
		self.chessBoardController.opposite = UserPreference.shared.game.opposite
	}
	
}

// MARK: - Action.
extension GameVC {
	
	@objc private func newGame() {
		GameSettingsView().show(isNew: true, delegate: self.chessBoardController)
	}
	
	@objc private func settings() {
		GameSettingsView().show(isNew: false, delegate: self.chessBoardController)
	}
	
	@objc private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
	@objc private func regretOneStep() {
		self.chessBoardController.complexRegret()
	}
	
	@objc private func teachMe() {
		self.setFlashProgress(progress: Float.random)
	}
	
	@objc private func showMenu() {
		LoadingAlertView.show(in: self.view, message: "加载中...", isCloseButtonHidden: false)
	}
	
}
