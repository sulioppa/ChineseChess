//
//  EditVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/10.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

protocol EditVCDelegate: NSObjectProtocol {
	func didDoneEdit(with file: String)
}

class EditVC: ChessVC {

	private lazy var chessBoardController: GameBoardController = GameBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: true)
	
	public weak var delegate: EditVCDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.layoutTopAndBottom(target: self, attributes: [
			("载 入", #selector(load)),
			("反 转", #selector(reverse)),
			("返 回", #selector(back)),
			("初 始", #selector(reset)),
			("清 空", #selector(clear)),
			("完 成", #selector(ok)),
			])
		
		self.chessBoardController.reverse = false
		self.refreshTopBottom(isReverse: self.chessBoardController.reverse)
    }

	public override func updateUserPreference() {
		
	}
	
}

// MARK: - Action.
extension EditVC: HistoryViewDelegate {
	
	@objc private func load() {
		HistoryView(delegate: self).show()
	}
	
	func historyView(didLoad file: String) {
		self.delegate?.didDoneEdit(with: file)
		self.dismiss()
	}
	
	@objc private func back() {
		WavHandler.playButtonWav()
		self.dismiss()
	}
	
}

// MARK: - Board
extension EditVC {
	
	@objc private func reverse() {
		WavHandler.playVoice(state: .normal)
		self.refreshTopBottom(isReverse: self.chessBoardController.reverse.reverse())
	}
	
	private func refreshTopBottom(isReverse: Bool) {
		if isReverse {
			self.setSideState(top: .red, bottom: .black)
		} else {
			self.setSideState(top: .black, bottom: .red)
		}
	}
	
	@objc private func reset() {
		
	}
	
	@objc private func clear() {
		
	}
	
	@objc private func ok() {
		
	}
	
}
