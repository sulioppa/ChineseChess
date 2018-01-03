//
//  HistoryView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/2.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class HistoryView: NavigationView {
	
	private lazy var tableview: UITableView = { [weak self] in
		let view = UITableView(frame: .zero, style: .grouped)
		view.backgroundColor = .clear
		view.delegate = self
		view.dataSource = self
		view.allowsMultipleSelection = false
		view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
		view.isScrollEnabled = false
		view.separatorInset = .zero
		view.separatorStyle = .singleLine
		return view
		}()
	
	public typealias DataItem = (chess: Int, text: String, eat: Int)
	public var dataSource: [DataItem] = []
	
	init() {
		super.init(frame: .zero)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

// MARK: - UITableViewDelegate
extension HistoryView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Cell.height
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return Cell.height / 2.0
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
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		cell.reloadCell(with: self.dataSource[indexPath.row], isRed: indexPath.row.isEven)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}

// MARK: - Cell
extension HistoryView {
	
	private class Cell: UITableViewCell {
		public static let identifier: String = {
			return "Cell"
		}()
		
		public static let edge: CGFloat = {
			return LayoutPartner.ChessBoard().boardmargin
		}()
		
		public static let height: CGFloat = {
			return LayoutPartner.ChessBoard().chessSize + 4.0
		}()
		
		public static let width: CGFloat = {
			return LayoutPartner.safeArea.size.width - (LayoutPartner.ChessBoard().boardmargin + Cell.edge) * 2.0
		}()
		
		public static let estimatedHeight: CGFloat = {
			return Cell.width
		}()
		
		private weak var chess: UIImageView?
		private weak var step: UILabel?
		private weak var eat: UIImageView?
		
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
			
			let eat = UIImageView()
			self.contentView.addSubview(eat)
			eat.snp.makeConstraints {
				$0.right.equalTo(self.contentView).offset(-3.0)
				$0.centerY.equalTo(self.contentView)
				$0.width.equalTo(layout.chessSize)
				$0.height.equalTo(layout.chessSize)
			}
			
			let step: UILabel = {
				let label = UILabel()
				label.textColor = UIColor.china
				label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().titleFontSize - 2.0)
				label.textAlignment = .center
				return label
			}()
			
			self.contentView.addSubview(step)
			step.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.left.equalTo(chess.snp.right).offset(3.0)
				$0.right.equalTo(eat.snp.left).offset(-3.0)
			}
			
			self.chess = chess
			self.step = step
			self.eat = eat
		}
		
		required public init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		public func reloadCell(with item: DataItem, isRed: Bool) {
			self.chess?.image = ResourcesProvider.shared.chess(index: item.chess)
			self.step?.textColor = isRed ? .china : .carbon
			self.step?.text = item.text
			self.eat?.image = ResourcesProvider.shared.chess(index: item.eat)
		}
	}
	
	private class HeaderView: UITableViewHeaderFooterView {
		
	}
	
}
