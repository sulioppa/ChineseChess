//
//  CharacterView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/2.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

@objc protocol CharacterViewDelegate: NSObjectProtocol {
	
	@objc optional func characterView(didSelectAt row: Int)
	
	@objc optional func characterView(didClickAt index: Int)
	
	@objc optional var detail: String { get }
	
}

class CharacterView: NavigationView {
	
	private var roundsLabel: UILabel?
	private var resultLabel: UILabel?
	
	private lazy var tableview: UITableView = { [weak self] in
		let view = UITableView(frame: .zero, style: .grouped)
		view.backgroundColor = UIColor(white: 1.0, alpha: LayoutPartner.NavigationView().backgroundColorAlpha)
		view.delegate = self
		view.dataSource = self
		view.allowsMultipleSelection = false
		view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
		view.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
		view.separatorInset = .zero
		view.separatorStyle = .singleLine
		return view
		}()
	
	public typealias DataItem = (chess: Int, text: String, eat: Int)
	
	private var dataSource: [DataItem] = []
	private weak var delegate: CharacterViewDelegate? = nil
	
	init(delegate: CharacterViewDelegate?, dataSource: [DataItem], result: String, index: Int? = nil) {
		super.init(frame: .zero)
		self.delegate = delegate
		self.bar.title = "棋  谱"
		self.bar.rightBarButtonItem?.image = ResourcesProvider.shared.image(named: "tips")
		self.bar.rightBarButtonItem?.addTapTarget(self, action: #selector(self.showDetail(gesture:)))
		
		// label
		let fontSize = LayoutPartner.NavigationView().smallTitleFontSize
		func createLabel() -> UILabel {
			let label = UILabel()
			label.textColor = UIColor.carbon
			label.font = UIFont.kaitiFont(ofSize: fontSize)
			label.textAlignment = .center
			return label
		}
		
		var label = createLabel()
		self.roundsLabel = label
		self.contentView.addSubview(label)
		label.snp.makeConstraints {
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.top.equalTo(self.contentView).offset(Cell.edge)
			$0.height.equalTo(fontSize + 4.0)
		}
		
		label = createLabel()
		self.resultLabel = label
		self.contentView.addSubview(label)
		label.snp.makeConstraints {
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.top.equalTo(self.contentView).offset(Cell.edge)
			$0.height.equalTo(fontSize + 4.0)
		}
		
		// button
		func createButton() -> UIButton {
			let button = UIButton()
			button.backgroundColor = UIColor.white
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitleColor(.china, for: .normal)
			button.setTitleColor(.red, for: .highlighted)
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
		
		var button = createButton()
		button.tag = 0
		button.setTitle("保 存 棋 谱", for: .normal)
		button.addTarget(self, action: #selector(self.didClickButton(sender:)), for: .touchUpInside)
		self.contentView.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(self.contentView)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(line.snp.left)
			$0.height.equalTo(Cell.height)
		}
		
		button = createButton()
		button.tag = 1
		button.setTitle("复 制 棋 谱", for: .normal)
		button.addTarget(self, action: #selector(self.didClickButton(sender:)), for: .touchUpInside)
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
		
		// tableview
		self.contentView.addSubview(self.tableview)
		self.tableview.snp.makeConstraints {
			$0.width.equalTo(Cell.width)
			$0.height.equalTo(Cell.estimatedHeight)
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.top.equalTo(label.snp.bottom).offset(3.0)
			$0.bottom.equalTo(button.snp.top).offset(-Cell.edge)
		}
		
		self.setDataSource(dataSource: dataSource, result: result, index: index)
		
		NotificationCenter.default.addObserver(forName: Macro.NotificationName.didUpdateOneStep, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
			if let item = notification.userInfo?["item"] as? DataItem {
				self?.didInsert(item: item, result: notification.userInfo?["result"] as? String)
			}
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
}

// MARK: - Private
extension CharacterView {
	
	private func didInsert(item: DataItem, result: String?) {
		self.dataSource.append(item)
		self.tableview.insert(indexPaths: [IndexPath(row: self.dataSource.count - 1, section: 0)])
		self.refreshRounds(index: nil, scroll: false)
		self.refreshResult(result: result ?? "结果: 未知")
	}
	
	private func setDataSource(dataSource: [DataItem], result: String, index: Int?) {
		self.dataSource = dataSource
		self.tableview.reloadData()
		self.refreshRounds(index: index, scroll: true)
		self.refreshResult(result: result)
	}
	
	private func refreshRounds(index: Int?, scroll: Bool) {
		let now: Int = index ?? self.dataSource.count - 1
		self.roundsLabel?.text = "回合数: \((now + 2) >> 1) / \((self.dataSource.count + 1) >> 1)"
		
		if scroll && now >= 0 {
			self.tableview.scrollToRow(at: IndexPath(row: now, section: 0), at: .top, animated: true)
		}
	}
	
	private func refreshResult(result: String) {
		self.resultLabel?.text = result
	}
	
	@objc private func didClickButton(sender: UIButton) {
		sender.isEnabled = false
		defer {
			sender.isEnabled = true
		}
		
		self.dismiss()
		self.delegate?.characterView?(didClickAt: sender.tag)
	}
	
	@objc private func showDetail(gesture: UIGestureRecognizer) {
		gesture.isEnabled = false
		defer {
			gesture.isEnabled = true
		}
		
		WavHandler.playButtonWav()
		TextAlertView.show(in: self.superview, text: self.delegate?.detail)
	}
	
}

// MARK: - UITableViewDelegate
extension CharacterView: UITableViewDelegate, UITableViewDataSource, CharacterViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Cell.height
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Cell.height
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1.0
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as! HeaderView
		view.delegate = self
		return view
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
		cell.reloadCell(with: self.dataSource[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.characterView(didSelectAt: indexPath.row)
	}
	
	func characterView(didSelectAt row: Int) {
		guard self.delegate?.responds(to: #selector(characterView(didSelectAt:))) == true else { return }
		
		self.refreshRounds(index: row, scroll: false)
		self.delegate?.characterView?(didSelectAt: row)
	}
	
}

// MARK: - Cell
extension CharacterView {
	
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
		
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
				label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
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
		
		public func reloadCell(with item: DataItem) {
			self.chess?.image = ResourcesProvider.shared.chess(index: item.chess)
			self.step?.textColor = item.chess < 32 ? .china : .carbon
			self.step?.text = item.text
			self.eat?.image = ResourcesProvider.shared.chess(index: item.eat)
		}
	}
	
	private class HeaderView: UITableViewHeaderFooterView {
		
		public static let identifier: String = "Header"
		
		public weak var delegate: CharacterViewDelegate? = nil
		
		private lazy var button: UIButton = {
			let button = UIButton()
			button.backgroundColor = UIColor.clear
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitle("开  局", for: .normal)
			button.setTitleColor(.china, for: .normal)
			button.setTitleColor(.red, for: .highlighted)
			return button
		}()
		
		override init(reuseIdentifier: String?) {
			super.init(reuseIdentifier: reuseIdentifier)
			self.contentView.backgroundColor = UIColor.clear
			
			self.button.addTarget(self, action: #selector(self.didSelectHeaderView(sender:)), for: .touchUpInside)
			self.contentView.addSubview(self.button)
			self.button.snp.makeConstraints {
				$0.edges.equalToSuperview()
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		@objc private func didSelectHeaderView(sender: UIButton) {
			sender.isEnabled = false
			defer {
				sender.isEnabled = true
			}
			
			self.delegate?.characterView?(didSelectAt: -1)
		}
	}
	
}
