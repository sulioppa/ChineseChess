//
//  GameBoardController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/28.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameBoardController: ChessBoardController {
	
	public init(board: UIView, AI: Luna) {
		super.init(board: board, AI: AI, isUserInteractionEnabled: true)
	}
	
	// MARK: - Handle Tap
	public override func didTapInBoard(at point: ChessBoardController.GridPoint) {
		print(point.description)
	}
}
