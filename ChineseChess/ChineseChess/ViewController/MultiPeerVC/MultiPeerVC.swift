//
//  MultiPeerVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class MultiPeerVC: ChessVC {
	
	private lazy var chessBoardController: MultiPeerBoardController = MultiPeerBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: true)
	
	private var rivalname: String = UserPreference.shared.multiPeer.rivalname

	private lazy var multiPeerMenuView: NavigationView? = MultiPeerMenuView(delegate: self)
	private weak var multipeerManager: MultipeerManager? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("认 输", #selector(lose)),
			("提 和", #selector(draw)),
			("离 开", #selector(leave)),
			("聊 天", #selector(chat)),
			("悔 棋", #selector(regret)),
			("棋 谱", #selector(showHistory)),
			])
		
		self.setSideState(top: .black, bottom: .red)
		self.setNickname(top: self.rivalname, bottom: UserPreference.shared.multiPeer.nickname)
		
		self.chessBoardController.refreshBoard()
		
		self.multipeerManager = MultipeerManager.shared
		self.multipeerManager?.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.multiPeerMenuView?.show(withVoice: nil)
	}
	
	public override func updateUserPreference() {
		UserPreference.shared.savePreference()
	}

}

// MARK: - MultiPeerMenuViewDelegate
extension MultiPeerVC: MultiPeerMenuViewDelegate, MultipeerManagerDelegate, LoadingAlertViewDelegate {
	
	func multiPeerMenuView(_ menuView: NavigationView, didSelectAt index: Int) {		
		switch index {
		case -1:
			self.back()
		case 0:
			self.create()
		case 1:
			self.join()
		case 2:
			self.changeNickname()
		default:
			break
		}
	}
	
	private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
	private func create() {
		LoadingAlertView.show(message: "等待加入中...", isCloseButtonHidden: false, delegate: self)
		self.multipeerManager?.start(isBroswerMode: false, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func join() {
		self.multipeerManager?.start(isBroswerMode: true, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func changeNickname() {
		
	}
	
	func multipeerManager(_ manager: MultipeerManager, state: MultipeerManagerConnectionState, name: String) {
		
	}
	
	func multipeerManager(_ manager: MultipeerManager, didReceive dictionary: [String : Any]) {
		
	}
	
	func loadingAlertViewDidDisappear(view: LoadingAlertView) {
		self.multipeerManager?.stop()
	}
	
}

// MARK: - Other
extension MultiPeerVC {
	
	@objc private func lose() {
		
	}
	
	@objc private func draw() {
		
	}
	
	@objc private func regret() {
		
	}
	
	@objc private func chat() {
		
	}
	
}

// MARK: - Back & Menu
extension MultiPeerVC: CharacterViewDelegate {
	
	@objc private func leave() {
		self.back()
	}
	
	@objc private func showHistory() {
		CharacterView(delegate: self, dataSource: self.AI.records.map({ return $0.item }), result: self.AI.state.result).show()
	}
	
	func characterView(didClickAt index: Int) {
		if index == 0 {
			UserPreference.shared.history.save(time: Date.time, name: self.name, description: self.detail, file: self.AI.historyFile())
			TextAlertView.show(in: self.contentView, text: "棋谱已保存")
		} else {
			UIPasteboard.general.string = "\(self.detail)\n\(self.AI.characters)"
			TextAlertView.show(in: self.contentView, text: "棋谱已复制到剪贴板")
		}
	}
	
	var detail: String {
		let red = self.chessBoardController.reverse ? self.rivalname : UserPreference.shared.multiPeer.nickname
		let black = self.chessBoardController.reverse ? UserPreference.shared.multiPeer.nickname : self.rivalname
		
		return "红方：\(red)\n黑方：\(black)\n回合数：\((self.AI.count + 1) >> 1)\n步数：\(self.AI.count)\n\(self.AI.state.result)"
	}
	
	private var name: String {
		let red = self.chessBoardController.reverse ? self.rivalname : UserPreference.shared.multiPeer.nickname
		let black = self.chessBoardController.reverse ? UserPreference.shared.multiPeer.nickname : self.rivalname
		
		return "\(red) \(self.AI.state.vs) \(black)"
	}
	
}
