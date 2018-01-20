//
//  HistoryMenuView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/20.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class HistoryMenuView: MenuView {
	
	public override func initDataSource() {
		self.dataSource.append(("reverse", "反 转 棋 盘", UserPreference.shared.history.reverse.chinese))
		self.dataSource.append(("opposite", "反 向 棋 子", UserPreference.shared.history.opposite.chinese))
		self.dataSource.append(("history", "查 看 棋 谱", nil))
		self.dataSource.append(("put", "对 弈 模 式", nil))
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.allowsSelection = false
		defer {
			tableView.allowsSelection = true
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			WavHandler.playVoice(state: .normal)
			self.dataSource[indexPath.row].status = UserPreference.shared.history.reverse.reverse().chinese
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else if indexPath.row == 1 {
			WavHandler.playVoice(state: .normal)
			self.dataSource[indexPath.row].status = UserPreference.shared.history.opposite.reverse().chinese
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
		
		self.delegate?.menuView(self, didSelectRowAt: indexPath.row)
	}
	
}

extension Bool {
	
	fileprivate var chinese: String {
		return self ? "是" : "否"
	}
	
}
