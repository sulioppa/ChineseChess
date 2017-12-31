//
//  GameMenuView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/31.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class GameMenuView: MenuView {
		
	public override func initDataSource() {
		self.dataSource.append(("reverse", "反 转 棋 盘", UserPreference.shared.game.reverse.chinese))
		self.dataSource.append(("opposite", "反 向 棋 子", UserPreference.shared.game.opposite.chinese))
		self.dataSource.append(("history", "查 看 棋 谱", nil))
		self.dataSource.append(("put", "摆 设 棋 局", nil))
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		cell.setDataItem(item: self.dataSource[indexPath.row])
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.allowsSelection = false
		defer {
			tableView.allowsSelection = true
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			WavHandler.playVoice(state: .normal)
			self.dataSource[indexPath.row].status = UserPreference.shared.game.reverse.reverse().chinese
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else if indexPath.row == 1 {
			WavHandler.playVoice(state: .normal)
			self.dataSource[indexPath.row].status = UserPreference.shared.game.opposite.reverse().chinese
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else {
			WavHandler.playButtonWav()
		}
		
		self.delegate?.menuView(didSelectRowAt: indexPath.row)
	}
	
}

extension Bool {
	
	fileprivate var chinese: String {
		return self ? "是" : "否"
	}
	
}
