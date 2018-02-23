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
	
	private weak var manager: MultipeerManager? = MultipeerManager.shared
	
	// navigation view
	private lazy var menuView: NavigationView? = MultiPeerMenuView(delegate: self)
		
	// rival information
	private var rivalname: String = UserPreference.shared.multiPeer.rivalname {
		didSet {
			self.setNickname(top: self.rivalname, bottom: UserPreference.shared.multiPeer.nickname)
		}
	}
	
	private var state: Int = 0
	
	// message control
	private var hasResponse: Bool = false
	
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
		self.chessBoardController.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.menuView?.show(in: self.view, withVoice: nil)
	}
	
	public override func updateUserPreference() {
		UserPreference.shared.savePreference()
	}
	
}

// MARK: - MultiPeerMenuViewDelegate
extension MultiPeerVC: MultiPeerMenuViewDelegate {
	
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
		self.manager?.disconnect()
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
	private func create() {
		LoadingAlertView.show(message: "等待加入中...", isCloseButtonHidden: false, delegate: self)
		self.manager?.start(isBroswerMode: false, delegate: self, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func join() {
		self.manager?.start(isBroswerMode: true, delegate: self, viewcontroller: self, displayName: UserPreference.shared.multiPeer.nickname)
	}
	
	private func changeNickname() {
		func refreshNickname(nickname: String) {
			guard !nickname.isEmpty else { return }
			
			UserPreference.shared.multiPeer.nickname = nickname
			self.setNickname(top: self.rivalname, bottom: nickname)
		}

		InputAlertView(title: "修 改 昵 称", placeholder: "请输入昵称", left: ("确  定", { (text) in
			WavHandler.playButtonWav()
			refreshNickname(nickname: text)
		}), right: ("取  消", { (text) in
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
}

// MARK: - MultipeerManagerDelegate
extension MultiPeerVC: MultipeerManagerDelegate, LoadingAlertViewDelegate {
	
	func multipeerManager(_ manager: MultipeerManager, state: MultipeerManagerConnectionState, name: String) {
		switch state {
		case .connecting:
			self.rivalname = name
		case .connected:
			self.connected(!manager.isBroswerMode)
		case .disconnected:
			self.disconnected()
		}
	}
	
	func multipeerManager(_ manager: MultipeerManager, didReceive dictionary: [String : Any]) {
		MultiPeerJson.type(json: dictionary) { (type, data) in
			switch type {
			case .newGame:
				self.didReceiveCreateGame(history: data["record"], isRed: data["red"])
			case .move:
				self.didReceiveMove(move: data["move"])
			case .lose:
				self.didReceiveLose(state: 1)
			case .chat:
				self.didReceiveChat(message: data["msg"])
			case .request:
				self.didReceiveRequest(type: data["type"])
			case .response:
				self.didReceiveResponse(type: data["type"])
			default:
				break
			}
		}
	}
	
	func loadingAlertViewDidDisappear(view: LoadingAlertView) {
		self.manager?.stop()
	}
	
}

// MARK: - Creating Game
extension MultiPeerVC {
	
	private func connected(_ isPositive: Bool) {
		self.menuView?.dismiss(withVoice: nil)
		self.menuView = nil
		
		guard isPositive else { return }
		
		LoadingAlertView.hide(animation: false) {
			self.createGame()
		}
	}
	
	private func disconnected() {
		UserPreference.shared.multiPeer.record = self.AI.historyFile()
		
		PromptAlertView(title: "提  示", message: "对局中断，离开此界面后重新进入，再次连接即可继续对局", action: ("我 知 道 了", false, {
			self.back()
		})).show(in: self.view)
	}
	
	private func createGame() {
		if UserPreference.shared.multiPeer.record.isEmpty {
			UserPreference.shared.multiPeer.red = true
		}
		
		self.startGame(history: UserPreference.shared.multiPeer.record)
		self.manager?.write(dictionary: MultiPeerJson.json(type: .newGame, parameters: [
			"record" : UserPreference.shared.multiPeer.record,
			"red": UserPreference.shared.multiPeer.red
			]))
	}
	
	private func recreateGame() {
		UserPreference.shared.multiPeer.record = .empty
		let red = UserPreference.shared.multiPeer.red.reverse()
		
		self.startGame(history: UserPreference.shared.multiPeer.record)
		self.manager?.write(dictionary: MultiPeerJson.json(type: .newGame, parameters: [
			"record" : UserPreference.shared.multiPeer.record,
			"red": red
			]))
	}
	
	private func didReceiveCreateGame(history: Any?, isRed: Any?) {
		guard let history = history as? String, let isRed = isRed as? Bool else { return }
		
		UserPreference.shared.multiPeer.red = !isRed
		self.startGame(history: history)
	}
	
	private func startGame(history: String) {
		self.chessBoardController.createGame(with: history)
		self.hasResponse = self.AI.state.rawValue == UserPreference.shared.multiPeer.red.rawValue
		
		if UserPreference.shared.multiPeer.red {
			self.setSideState(top: .black, bottom: .red)
		} else {
			self.setSideState(top: .red, bottom: .black)
		}
	}
	
}

// MARK: - Connected
extension MultiPeerVC: MultiPeerBoardControllerDelegate {
	
	func multiPeerBoardController(didMove oneStep: LunaMove) {
		self.hasResponse = false
		self.manager?.write(dictionary: MultiPeerJson.json(type: .move, parameters: [
			"move" : oneStep
			]))
	}
	
	private func didReceiveMove(move: Any?) {
		guard let move = move as? LunaMove else { return }
		
		self.chessBoardController.moveOneStep(move: move)
		self.hasResponse = true
	}
	
	func multiPeerBoardControllerWillEndTheGame() {
		NotificationCenter.default.post(name: Macro.NotificationName.willShowAnotherAlertView, object: nil)
	}
	
	func multiPeerBoardControllerDidEndTheGame(isNormal: Bool) {
		if isNormal {
			UserPreference.shared.history.save(time: Date.time, name: self.name, description: self.detail, file: self.AI.historyFile())
		} else {
			UserPreference.shared.history.save(time: Date.time, name: self.stateName, description: self.stateDetail, file: self.AI.historyFile())
		}
		
		self.hasResponse = false
		UserPreference.shared.multiPeer.record = .empty
		MultiPeerWaittingView().show(in: self.view, withVoice: nil)
	}
	
	var canRequest: Bool {
		return self.hasResponse
	}
	
	private var stateName: String {
		if self.chessBoardController.reverse {
			return "\(self.rivalname) \(self.stateVS) \(UserPreference.shared.multiPeer.nickname)"
		} else {
			return "\(UserPreference.shared.multiPeer.nickname) \(self.stateVS) \(self.rivalname)"
		}
	}
	
	private var stateDetail: String {
		if self.chessBoardController.reverse {
			return "红方：\(self.rivalname)\n黑方：\(UserPreference.shared.multiPeer.nickname)\n回合数：\((self.AI.count + 1) >> 1)\n步数：\(self.AI.count)\n结果：\(self.stateResult)"
		} else {
			return "红方：\(UserPreference.shared.multiPeer.nickname)\n黑方：\(self.rivalname)\n回合数：\((self.AI.count + 1) >> 1)\n步数：\(self.AI.count)\n结果：\(self.stateResult)"
		}
	}
	
	private var stateDescription: String {
		if self.state == 0 {
			return "双方议和"
		} else if self.state > 0 {
			return "对方认输"
		} else {
			return "认输"
		}
	}
	
	private var stateVS: String {
		if self.state == 0 {
			return "先和"
		} else if self.state > 0 {
			return "先胜"
		} else {
			return "先负"
		}
	}
	
	private var stateResult: String {
		if self.state == 0 {
			return "双方议和"
		} else {
			if UserPreference.shared.multiPeer.red {
				return self.state > 0 ? "黑方认输" : "红方认输"
			} else {
				return self.state > 0 ? "红方认输" : "黑方认输"
			}
		}
	}
	
}

// MARK: - Request & Response
extension MultiPeerVC {
	
	@objc private func lose() {
		WavHandler.playButtonWav()
		
		guard self.hasResponse else {
			TextAlertView.show(in: self.contentView, text: "现在不能认输")
			return
		}
		
		PromptAlertView(title: "提  示", message: "确定要认输吗？", left: ("认 输", true, {
			WavHandler.playButtonWav()
			self.hasResponse = false
			
			self.manager?.write(dictionary: MultiPeerJson.json(type: .lose, parameters: [ : ]))
			self.didChangeState(state: -1, isPositive: true)
		}), right: ("取 消", false, {
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	private func didReceiveLose(state: Int) {
		self.didChangeState(state: state, isPositive: false)
	}
	
	@objc private func draw() {
		WavHandler.playButtonWav()
		
		guard self.hasResponse else {
			TextAlertView.show(in: self.contentView, text: "现在不能提和")
			return
		}
		
		PromptAlertView(title: "提  示", message: "确定要提和吗？", left: ("提 和", false, {
			WavHandler.playButtonWav()
			self.hasResponse = false
			
			self.manager?.write(dictionary: MultiPeerJson.json(type: .request, parameters: [
				"type": MultiPeerJson.MessageType.draw.rawValue
				]))
		}), right: ("取 消", false, {
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	private func didReceiveDraw() {
		self.didChangeState(state: 0, isPositive: false)
	}
	
	private func didChangeState(state: Int, isPositive: Bool) {
		self.state = isPositive ? state : -state
		self.multiPeerBoardControllerWillEndTheGame()
		BladeAlertView.show(in: self.contentView, text: self.stateDescription) {
			self.multiPeerBoardControllerDidEndTheGame(isNormal: false)
		}
	}
	
	@objc private func regret() {
		WavHandler.playButtonWav()
		
		guard self.hasResponse && self.AI.count > 1 else {
			TextAlertView.show(in: self.contentView, text: "现在不能悔棋")
			return
		}
		
		PromptAlertView(title: "提  示", message: "确定要悔棋吗？", left: ("悔 棋", false, {
			WavHandler.playButtonWav()
			self.hasResponse = false
			self.manager?.write(dictionary: MultiPeerJson.json(type: .request, parameters: [
				"type": MultiPeerJson.MessageType.regret.rawValue
				]))
		}), right: ("取 消", false, {
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	private func didReceiveRegret() {
		self.chessBoardController.complexRegret()
		self.hasResponse = self.AI.state.rawValue == UserPreference.shared.multiPeer.red.rawValue
	}
	
	private func didReceiveRequest(type: Any?) {
		guard let rawValue = type as? Int else { return }
		guard let type = MultiPeerJson.MessageType(rawValue: rawValue) else { return }
		
		switch type {
		case .regret:
			PromptAlertView(title: "提  示", message: "对方向您请求悔棋", left: ("同 意", false, {
				self.manager?.write(dictionary: MultiPeerJson.json(type: .response, parameters: [
					"type": MultiPeerJson.MessageType.regret.rawValue
					]))
				self.chessBoardController.complexRegret()
			}), right: ("拒 绝", false, {
				WavHandler.playButtonWav()
				self.manager?.write(dictionary: MultiPeerJson.json(type: .response, parameters: [
					"type": MultiPeerJson.MessageType.turndown.rawValue
					]))
			})).show(in: self.view)
			
		case .draw:
			PromptAlertView(title: "提  示", message: "对方向您请求和棋", left: ("同 意", false, {
				self.manager?.write(dictionary: MultiPeerJson.json(type: .response, parameters: [
					"type": MultiPeerJson.MessageType.draw.rawValue
					]))
				self.didReceiveDraw()
			}), right: ("拒 绝", false, {
				WavHandler.playButtonWav()
				self.manager?.write(dictionary: MultiPeerJson.json(type: .response, parameters: [
					"type": MultiPeerJson.MessageType.turndown.rawValue
					]))
			})).show(in: self.view)
			
		default:
			break
		}
	}
	
	private func didReceiveResponse(type: Any?) {
		guard let rawValue = type as? Int else { return }
		guard let type = MultiPeerJson.MessageType(rawValue: rawValue) else { return }
		
		switch type {
		case .regret:
			self.didReceiveRegret()
		case .draw:
			self.didReceiveDraw()
		case .turndown:
			TextAlertView.show(in: self.contentView, text: "对方拒绝了您的请求")
			self.hasResponse = true
		default:
			break
		}
	}
	
	// Chat
	@objc private func chat() {
		WavHandler.playButtonWav()
		
		InputAlertView(title: "聊  天", placeholder: "请输入非空的聊天内容", left: ("发 送", { (content) in
			WavHandler.playButtonWav()
			guard !content.isEmpty else { return }
			
			self.manager?.write(dictionary: MultiPeerJson.json(type: .chat, parameters: [
				"msg": content
				]))
			self.didReceiveChat(message: content)
		}), right: ("取消", { (_) in
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	private func didReceiveChat(message: Any?) {
		guard let _ = message as? String else { return }
		
	}
	
}

// MARK: - Back & History
extension MultiPeerVC: CharacterViewDelegate {
	
	@objc private func leave() {
		WavHandler.playButtonWav()
		
		PromptAlertView(title: "提  示", message: "当前对局将不会被保存，确定要离开此界面？", left: ("离  开", false, {
			UserPreference.shared.multiPeer.record = .empty
			self.back()
		}), right: ("取  消", false, {
			WavHandler.playButtonWav()
		})).show(in: self.view)
	}
	
	@objc private func showHistory() {
		CharacterView(delegate: self, dataSource: self.AI.records.map({ return $0.item }), result: self.AI.state.result).show(in: self.view)
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
		
		return "红方：\(red)\n黑方：\(black)\n回合数：\((self.AI.count + 1) >> 1)\n步数：\(self.AI.count)\n\(self.AI.state.description)"
	}
	
	private var name: String {
		let red = self.chessBoardController.reverse ? self.rivalname : UserPreference.shared.multiPeer.nickname
		let black = self.chessBoardController.reverse ? UserPreference.shared.multiPeer.nickname : self.rivalname
		
		return "\(red) \(self.AI.state.vs) \(black)"
	}
	
}
