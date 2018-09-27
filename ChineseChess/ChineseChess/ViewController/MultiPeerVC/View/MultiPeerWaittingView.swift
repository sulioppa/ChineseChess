//
//  MultiPeerWaittingView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/24.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

protocol MultiPeerWaittingViewDelegate: NSObjectProtocol {
	
	func multiPeerWaittingView(shouldStartGame waittingView: MultiPeerWaittingView)
	
	func multiPeerWaittingView(willCancel waittingView: MultiPeerWaittingView)
	
}

class MultiPeerWaittingView: NavigationView {
	
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
	
	private var isRivalReady: Bool = false
	
	private weak var manager: MultipeerManager? = nil
	
	private weak var delegate: MultiPeerWaittingViewDelegate? = nil
	
	private typealias DataItem = (name: String, status: String)
	
	private var dataSource: [DataItem] = []
	
	init(manager: MultipeerManager?, delegate: MultiPeerWaittingViewDelegate?, rivalName: String) {
		super.init(frame: .zero)
		self.manager = manager
		self.delegate = delegate
		
		self.bar.title = "新  局"
		
		if let gestureRecognizers = self.bar.leftBarButtonItem?.gestureRecognizers {
			for gesture in gestureRecognizers {
				self.bar.leftBarButtonItem?.removeGestureRecognizer(gesture)
			}
		}
		self.bar.leftBarButtonItem?.addTapTarget(self, action: #selector(self.back(sender:)))
		
		self.bar.rightBarButtonItem?.image = ResourcesProvider.shared.image(named: "tips")
		self.bar.addTapTarget(self, action: #selector(self.showTips(sender:)))
		
		self.dataSource = [(UserPreference.shared.multiPeer.nickname, "准备中..."), (rivalName, "准备中...")]
		
		// button
		func createButton(isRed: Bool = false) -> UIButton {
			let button = UIButton()
			button.backgroundColor = isRed ? .china : .white
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitleColor(isRed ? .white : .china, for: .normal)
			button.setTitleColor(.red, for: .highlighted)
			button.setTitleColor(.white, for: .disabled)
			return button
		}
		
		var line = UIView()
		line.backgroundColor = UIColor.separtor
		self.contentView.addSubview(line)
		line.snp.makeConstraints {
			$0.centerX.equalTo(self.contentView.snp.centerX)
			$0.bottom.equalTo(self.contentView)
			$0.height.equalTo(Cell.height)
			$0.width.equalTo(0.5)
		}
		
		var button = createButton(isRed: true)
		button.setTitle("准  备", for: .normal)
		button.addTarget(self, action: #selector(self.didGetReady(sender:)), for: .touchUpInside)
		self.contentView.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(self.contentView)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(line.snp.left)
			$0.height.equalTo(Cell.height)
		}
		
		button = createButton(isRed: false)
		button.setTitle("离  开", for: .normal)
		button.addTarget(self, action: #selector(self.willCancel(sender:)), for: .touchUpInside)
		self.contentView.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(line.snp.right)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(self.contentView)
			$0.height.equalTo(Cell.height)
		}
		
		line = UIView()
		line.backgroundColor = UIColor.separtor
		self.contentView.addSubview(line)
		line.snp.makeConstraints {
			$0.left.equalTo(self.contentView)
			$0.right.equalTo(self.contentView)
			$0.height.equalTo(0.5)
			$0.bottom.equalTo(button.snp.top)
		}
		
		self.contentView.addSubview(self.tableview)
		self.tableview.snp.makeConstraints {
			$0.top.equalTo(self.contentView).offset(Cell.height)
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.bottom.equalTo(button.snp.top).offset(-Cell.height)
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.width.equalTo(Cell.width)
			$0.height.equalTo(Cell.estimatedHeight(rows: self.dataSource.count))
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public final func didReceiveReady() {
		self.isRivalReady = true
		self.dataSource[1].status = "已准备"
		self.tableview.reloadData()
	}
	
	@objc private func didGetReady(sender: UIButton?) {
		sender?.backgroundColor = UIColor.disabled
		sender?.isEnabled = false
		
		self.dataSource[0].status = "已准备"
		self.tableview.reloadData()
		
		if self.isRivalReady {
			self.delegate?.multiPeerWaittingView(shouldStartGame: self)
		} else {
			self.manager?.write(dictionary: MultiPeerJson.json(type: .ready, parameters: [ : ]))
		}
	}
	
	@objc private func willCancel(sender: UIButton?) {
		sender?.isUserInteractionEnabled = false
		defer {
			sender?.isUserInteractionEnabled = true
		}
		
		self.back(sender: nil)
	}
	
}

// MARK: - Action.
extension MultiPeerWaittingView {
	
	@objc private func back(sender: UIGestureRecognizer?) {
		sender?.isEnabled = false
		defer {
			sender?.isEnabled = true
		}
		
		WavHandler.playButtonWav()
		self.delegate?.multiPeerWaittingView(willCancel: self)
	}
	
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

}

// MARK: - TableViewDelegate
extension MultiPeerWaittingView: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1.0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Cell.height
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1.0
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		let item = self.dataSource[indexPath.row]
		cell.setDataItem(item: item, isMe: indexPath.row == 0)
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
}

// MARK: - Internal Cell
extension MultiPeerWaittingView {
	
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
		
		private weak var title: UILabel?
		private weak var value: UILabel?
		
		private var label: UILabel {
			let label = UILabel()
			label.textColor = .carbon
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			label.textAlignment = .center
			return label
		}
		
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			let title = self.label
			self.contentView.addSubview(title)
			title.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.left.equalTo(self.contentView).offset(3.0)
			}
			
			let value = self.label
			self.contentView.addSubview(value)
			value.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.right.equalTo(self.contentView).offset(-3.0)
			}
			
			self.title = title
			self.value = value
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		public func setDataItem(item: DataItem, isMe: Bool) {
			self.title?.textColor = isMe ? .china : .carbon
			self.title?.text = item.name
			self.value?.text = item.status
		}
	}
	
}
