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

	private lazy var chessBoardController: EditBoardController = EditBoardController(contentView: self.contentView, board: self.board, AI: self.AI, isUserInteractionEnabled: true)
	
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

// MARK: - HistoryViewDelegate.
extension EditVC: HistoryViewDelegate {
	
	@objc private func load() {
		HistoryView(delegate: self).show()
	}
	
	var viewcontroller: UIViewController {
		return self
	}
	
	func historyView(didLoad file: String, name: String, detail: String) {
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
		WavHandler.playVoice(state: .normal)
		self.AI.resetBoard()
		self.chessBoardController.refreshBoard()
	}
	
	@objc private func clear() {
		WavHandler.playVoice(state: .normal)
		self.AI.clearBoard()
		self.chessBoardController.refreshBoard()
	}
	
	@objc private func ok() {
		func didSelectSide(side: LunaBoardState) {
			let state = self.AI.isEditDone(side)
			
			if state == .normal {
				self.delegate?.didDoneEdit(with: self.AI.historyFile())
				self.back()
			} else {
				TextAlertView.show(in: self.contentView, text: state.description(state: side))
			}
		}
		
		let controller = UIAlertController(title: "选择先手", message: nil, preferredStyle: .alert)
		controller.addAction(UIAlertAction(title: "红方", style: .default, handler: { (_) in
			didSelectSide(side: .turnRedSide)
		}))
		controller.addAction(UIAlertAction(title: "黑方", style: .default, handler: { (_) in
			didSelectSide(side: .turnBlackSide)
		}))
		
		self.present(controller, animated: true, completion: nil)
	}
	
}
