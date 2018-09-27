//
//  MultiPeerMenuView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/24.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

public protocol MultiPeerMenuViewDelegate: NSObjectProtocol {
	func multiPeerMenuView(_ menuView: NavigationView, didSelectAt index: Int)
}

class MultiPeerMenuView: NavigationView {

	private weak var delegate: MultiPeerMenuViewDelegate? = nil
	
	private lazy var tableview: UITableView = { [weak self] in
		let view = UITableView(frame: CGRect.zero, style: .grouped)
		view.backgroundColor = UIColor.clear
		view.delegate = self
		view.dataSource = self
		view.allowsMultipleSelection = false
		view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
		view.isScrollEnabled = false
		view.separatorInset = UIEdgeInsets.zero
		view.separatorStyle = .singleLine
		return view
		}()
	
	private let dataSource: [String] = [ "创 建 对 局", "加 入 对 局", "修 改 昵 称" ]
	
	init(delegate: MultiPeerMenuViewDelegate) {
		super.init(frame: .zero)
		self.delegate = delegate
		
		self.bar.title = "对 弈 大 厅"
		
		if let gestureRecognizers = self.bar.leftBarButtonItem?.gestureRecognizers {
			for gesture in gestureRecognizers {
				self.bar.leftBarButtonItem?.removeGestureRecognizer(gesture)
			}
		}
		self.bar.leftBarButtonItem?.addTapTarget(self, action: #selector(self.back(sender:)))
		
		self.bar.rightBarButtonItem?.image = ResourcesProvider.shared.image(named: "tips")
		self.bar.addTapTarget(self, action: #selector(self.showTips(sender:)))
		
		self.contentView.addSubview(self.tableview)
		self.tableview.snp.makeConstraints {
			$0.top.equalTo(self.contentView).offset(Cell.height / 2.0)
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.bottom.equalTo(self.contentView).offset(-Cell.height / 2.0)
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.width.equalTo(Cell.width)
			$0.height.equalTo(Cell.estimatedHeight(rows: self.dataSource.count))
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

// MARK: - UITableViewDelegate
extension MultiPeerMenuView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1.0
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
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		cell.label.text = self.dataSource[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.delegate?.multiPeerMenuView(self, didSelectAt: indexPath.row)
		WavHandler.playButtonWav()
	}
	
}

// MARK: - Cell & Action.
extension MultiPeerMenuView {
	
	@objc private func showTips(sender: UIGestureRecognizer?) {
		sender?.isEnabled = false
		defer {
			sender?.isEnabled = true
		}
		
		guard let data = ResourcesProvider.shared.bundle(named: "AppInformation", type: "txt") else { return }
		guard let text = String(data: data, encoding: .utf8) else { return }
		
		WavHandler.playButtonWav()
		TextAlertView.show(in: self.superview, text: text)
	}
	
	@objc private func back(sender: UIGestureRecognizer?) {
		sender?.isEnabled = false
		defer {
			sender?.isEnabled = true
		}
		
		self.dismiss(withVoice: nil)
		self.delegate?.multiPeerMenuView(self, didSelectAt: -1)
	}
	
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
		
		public class func estimatedHeight(rows: Int) -> CGFloat {
			return Cell.height * CGFloat(rows) + 2.0
		}
		
		public lazy var label: UILabel = {
			let label = UILabel()
			label.textColor = UIColor.china
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			label.textAlignment = .center
			return label
		}()
		
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			self.contentView.addSubview(self.label)
			self.label.snp.makeConstraints {
				$0.center.equalTo(self.contentView)
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
	
}
