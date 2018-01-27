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

	private lazy var menuView: NavigationView? = MultiPeerMenuView(delegate: self)
	private weak var manager: MultipeerManager? = nil
	
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
		
		self.manager = MultipeerManager.shared
		self.manager?.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.menuView?.show(in: self.view, withVoice: nil)
	}
	
	public override func updateUserPreference() {
		UserPreference.shared.savePreference()
	}

	private func refreshNickname(nickname: String) {
		guard !nickname.isEmpty else { return }
		
		UserPreference.shared.multiPeer.nickname = nickname
		self.setNickname(top: self.rivalname, bottom: nickname)
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
		self.manager?.start(isBroswerMode: false, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func join() {
		self.manager?.start(isBroswerMode: true, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func changeNickname() {
		InputAlertView(title: "修 改 昵 称", placeholder: "请输入昵称", left: ("确  定", { (text) in
			WavHandler.playButtonWav()
			self.refreshNickname(nickname: text)
		}), right: ("取  消", { (text) in
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	func multipeerManager(_ manager: MultipeerManager, state: MultipeerManagerConnectionState, name: String) {
		
	}
	
	func multipeerManager(_ manager: MultipeerManager, didReceive dictionary: [String : Any]) {
		
	}
	
	func loadingAlertViewDidDisappear(view: LoadingAlertView) {
		self.manager?.stop()
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
		WavHandler.playButtonWav()
		
		PromptAlertView(title: "提  示", message: "确定要离开此界面？", left: ("离  开", false, {
			self.back()
		}), right: ("取  消", false, {
			WavHandler.playButtonWav()
		})).show(in: self.view)
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
