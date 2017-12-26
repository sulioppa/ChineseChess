//
//  GameSettingsView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/25.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

protocol GameSettingsViewDelegate: NSObjectProtocol {
	func gameSettingsViewDidClickOk(isNew: Bool, levels: [UserPreference.Level])
}

class GameSettingsView: NavigationView {

	private lazy var tableview: UITableView = { [weak self] in
		let view = UITableView(frame: CGRect.zero, style: .grouped)
		view.backgroundColor = UIColor.clear
		view.delegate = self
		view.dataSource = self
		view.allowsMultipleSelection = false
		view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
		view.register(OkCell.self, forCellReuseIdentifier: OkCell.identifier)
		view.isScrollEnabled = false
		view.separatorInset = UIEdgeInsets.zero
		view.separatorStyle = .singleLine
		return view
	}()
	
	private typealias DataItem = (image: String, title: String, level: UserPreference.Level)
	
	private var dataSource: [DataItem] = []
	
	private var levels: [UserPreference.Level] {
		var array: [UserPreference.Level] = []
		for item in self.dataSource {
			array.append(item.level)
		}
		return array
	}
	
	private var delegate: GameSettingsViewDelegate?
	
	private var isNew: Bool = false {
		didSet {
			self.bar.title = isNew ? "新  局" : "设  置"
		}
	}
	
	public init() {
		super.init(frame: CGRect.zero)
		self.initDataSource()
		
		self.contentView.addSubview(self.tableview)
		self.tableview.snp.makeConstraints {
			$0.top.equalTo(self.contentView)
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.width.equalTo(Cell.width)
			$0.height.equalTo(Cell.estimatedHeight(rows: self.dataSource.count + 3))
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func initDataSource() {
		self.dataSource.append(("帥", "红 方", UserPreference.shared.game.red))
		self.dataSource.append(("將", "黑 方", UserPreference.shared.game.black))
		self.dataSource.append(("AI", "提 示 水 平", UserPreference.shared.game.prompt))
	}
	
	public func show(isNew: Bool, delegate: GameSettingsViewDelegate?) {
		self.isNew = isNew
		self.delegate = delegate
		self.show()
	}
	
}

// MARK: - UITableViewDelegate
extension GameSettingsView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return self.dataSource.count
		}
		
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Cell.height
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1.0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Cell.height
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section > 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: OkCell.identifier, for: indexPath) as! OkCell
			cell.okLabel.text = "确  定"
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		cell.setDataItem(item: self.dataSource[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.section > 0 {
			self.delegate?.gameSettingsViewDidClickOk(isNew: self.isNew, levels: self.levels)
			self.dismiss()
		} else {
			WavHandler.playButtonWav()
		}
	}
	
}

// MARK: - Cell
extension GameSettingsView {
	
	private class Cell: UITableViewCell {
		public static var identifier: String {
			return "Cell"
		}
		
		public static var edge: CGFloat {
			return 15.0
		}
		
		public static var height: CGFloat {
			return LayoutPartner.ChessBoard().chessSize + 4.0
		}
		
		public static var width: CGFloat {
			return LayoutPartner.safeArea.size.width - (LayoutPartner.ChessBoard().boardmargin + Cell.edge) * 2.0
		}
		
		public class func estimatedHeight(rows: Int) -> CGFloat {
			return Cell.height * CGFloat(rows) + 2.0
		}
		
		private weak var chess: UIImageView?
		private weak var title: UILabel?
		private weak var value: UILabel?
		
		public var label: UILabel {
			let label = UILabel()
			label.textColor = UIColor.china
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().titleFontSize - 2.0)
			label.textAlignment = .center
			return label
		}
		
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			let layout = LayoutPartner.ChessBoard()
			
			let chess = UIImageView()
			self.contentView.addSubview(chess)
			chess.snp.makeConstraints {
				$0.left.equalTo(self.contentView).offset(3.0)
				$0.centerY.equalTo(self.contentView)
				$0.width.equalTo(layout.chessSize)
				$0.height.equalTo(layout.chessSize)
			}
			
			let title = self.label
			self.contentView.addSubview(title)
			title.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.left.equalTo(chess.snp.right).offset(3.0)
			}
			
			let value = self.label
			self.contentView.addSubview(value)
			value.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.right.equalTo(self.contentView).offset(-3.0)
			}
			
			self.chess = chess
			self.title = title
			self.value = value
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		public func setDataItem(item: DataItem) {
			self.chess?.image = ResourcesProvider.shared.image(named: item.image)
			self.title?.text = item.title
			self.value?.text = item.level.description
		}
	}
	
	private class OkCell: UITableViewCell {
		public static var identifier: String {
			return "OkCell"
		}
		
		public lazy var okLabel: UILabel = {
			let label = UILabel()
			label.textColor = UIColor.china
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().titleFontSize)
			label.textAlignment = .center
			return label
		}()
		
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			self.contentView.addSubview(self.okLabel)
			self.okLabel.snp.makeConstraints {
				$0.center.equalTo(self.contentView)
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
	
}
