//
//  GameVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/16.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameVC: ChessVC {

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
		self.setSideState(top: .black, bottom: .red)
		self.setNickname(top: "棋手", bottom: "棋手")
	}
	
}

// MARK: - Action.
extension GameVC {
	
	@objc func newGame() {

	}
	
	@objc func settings() {
	
	}
	
	@objc func back() {
		WavHandler.playWav()
		self.dismiss()
	}
	
	@objc func regretOneStep() {
		
	}
	
	@objc func teachMe() {
		self.setFlashProgress(progress: Float.random)
	}
	
	@objc func showMenu() {
		
	}
	
}
