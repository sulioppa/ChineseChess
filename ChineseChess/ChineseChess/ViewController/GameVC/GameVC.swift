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
		self.AI.initBoard(withFile: UserPreference.shared.game.record)
		self.chessBoardController.reverse = UserPreference.shared.game.reverse
		self.chessBoardController.opposite = UserPreference.shared.game.opposite
		self.refreshTopBottom()
	}
	
	public override func updateUserPreference() {
		UserPreference.shared.game.record = self.AI.historyFile()
		UserPreference.shared.savePreference()
	}
	
}

// MARK: - GameSettings.
extension GameVC: GameSettingsViewDelegate {
	
	@objc private func newGame() {
		GameSettingsView().show(isNew: true, delegate: self)
	}
	
	@objc private func settings() {
		GameSettingsView().show(isNew: false, delegate: self)
	}
	
	func gameSettingsViewDidClickOk(isNew: Bool, levels: [UserPreference.Level]) {
		self.chessBoardController.gameSettingsViewDidClickOk(isNew: isNew, levels: levels)
		self.refreshTopBottom()
	}
	
	private func refreshTopBottom() {
		if UserPreference.shared.game.reverse {
			self.setSideState(top: ChessVC.SideState.side(level: UserPreference.shared.game.red, isRed: true), bottom: ChessVC.SideState.side(level: UserPreference.shared.game.black, isRed: false))
			self.setNickname(top: UserPreference.shared.game.red.description, bottom: UserPreference.shared.game.black.description)
		} else {
			self.setSideState(top: ChessVC.SideState.side(level: UserPreference.shared.game.black, isRed: false), bottom: ChessVC.SideState.side(level: UserPreference.shared.game.red, isRed: true))
			self.setNickname(top: UserPreference.shared.game.black.description, bottom: UserPreference.shared.game.red.description)
		}
	}
	
}

// MARK: - Menu.
extension GameVC: MenuViewDelegate {

	@objc private func showMenu() {
		GameMenuView().show(delegate: self)
	}
	
	func menuView(didSelectRowAt index: Int) {
		switch index {
		case 0:
			self.chessBoardController.reverse = UserPreference.shared.game.reverse
			self.refreshTopBottom()
		case 1:
			self.chessBoardController.opposite = UserPreference.shared.game.opposite
		case 2:
			break;
		case 3:
			break;
		default:
			break;
		}
	}
	
}

// MARK: - Other
extension GameVC {
	
	@objc private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
	@objc private func regretOneStep() {
		self.chessBoardController.complexRegret()
	}
	
	@objc private func teachMe() {
		
	}
	
}
