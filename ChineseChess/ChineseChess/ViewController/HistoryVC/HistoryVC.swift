//
//  HistoryVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class HistoryVC: ChessVC {

	private lazy var chessBoardController: HistoryBoardController = HistoryBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: false)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("载 入", #selector(load)),
			("棋 谱", #selector(showHistory)),
			("返 回", #selector(back)),
			("前 进", #selector(moveForward)),
			("回 退", #selector(backForward)),
			("菜 单", #selector(showMenu)),
			])
		
		self.chessBoardController.reverse = UserPreference.shared.history.reverse
		self.chessBoardController.opposite = UserPreference.shared.history.opposite
		self.setNickname(top: "", bottom: "")
		
		self.refreshTopBottom()
		self.initBoard()
    }

	public override func updateUserPreference() {
		UserPreference.shared.savePreference()
	}
	
	private func initBoard() {
		self.AI.initBoard(withFile: UserPreference.shared.history.record)
		self.chessBoardController.refreshBoard(at: UserPreference.shared.history.index)
	}
	
}

// MARK: - HistoryViewDelegate.
extension HistoryVC: HistoryViewDelegate {
	
	@objc private func load() {
		HistoryView(delegate: self).show()
	}
	
	var viewcontroller: UIViewController {
		return self
	}
	
	func historyView(didLoad file: String, name: String, detail: String) {
		self.AI.initBoard(withFile: file)
		
		UserPreference.shared.history.record = file
		UserPreference.shared.history.name = name
		UserPreference.shared.history.detail = detail
		UserPreference.shared.history.result = self.AI.state.result
		
		self.chessBoardController.refreshBoard(at: -1)
	}
	
	@objc private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
}

// MARK: - Character
extension HistoryVC: CharacterViewDelegate {
	
	@objc private func showHistory() {
		CharacterView(delegate: self, dataSource: self.AI.records.map({ return $0.item }), result: UserPreference.shared.history.result, index: UserPreference.shared.history.index).show()
	}
	
	func characterView(didClickAt index: Int) {
		if index == 0 {
			UserPreference.shared.history.save(time: Date.time, name: self.name, description: self.detail, file: UserPreference.shared.history.record)
			TextAlertView.show(in: self.contentView, text: "棋谱已保存")
		} else {
			UIPasteboard.general.string = "\(self.detail)\n\(self.AI.characters)"
			TextAlertView.show(in: self.contentView, text: "棋谱已复制到剪贴板")
		}
	}
	
	var detail: String {
		return UserPreference.shared.history.detail
	}
	
	private var name: String {
		return UserPreference.shared.history.name
	}
	
	func characterView(didSelectAt row: Int) {
		guard row != UserPreference.shared.history.index else { return }
		
		WavHandler.playVoice(state: .normal)
		self.chessBoardController.refreshBoard(at: row)
	}
	
}

// MARK: - Move & Back
extension HistoryVC {
	
	@objc private func moveForward() {
		self.chessBoardController.moveForward()
	}
	
	@objc private func backForward() {
		self.chessBoardController.backForward()
	}
	
}

// MARK: - Menu.
extension HistoryVC: MenuViewDelegate {
	
	@objc private func showMenu() {
		HistoryMenuView().show(delegate: self)
	}
	
	func menuView(_ menuView: NavigationView, didSelectRowAt index: Int) {
		switch index {
		case 0:
			self.chessBoardController.reverse = UserPreference.shared.history.reverse
			self.refreshTopBottom()
		case 1:
			self.chessBoardController.opposite = UserPreference.shared.history.opposite
		case 2:
			menuView.push(view: CharacterView(delegate: self, dataSource: self.AI.records.map({ return $0.item }), result: UserPreference.shared.history.result, index: UserPreference.shared.history.index))
		case 3:
			menuView.dismiss()
			UserPreference.shared.game.record = self.AI.historyFile(at: UserPreference.shared.history.index)
			self.present("GameVC")
		default:
			break
		}
	}
	
	private func refreshTopBottom() {
		if self.chessBoardController.reverse {
			self.setSideState(top: .red, bottom: .black)
		} else {
			self.setSideState(top: .black, bottom: .red)
		}
	}

}
