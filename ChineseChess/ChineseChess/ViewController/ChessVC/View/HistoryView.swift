//
//  HistoryView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/10.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

protocol HistoryViewDelegate: NSObjectProtocol {
	
	func historyView(didLoad file: String, name: String, detail: String)
	
	var viewcontroller: UIViewController { get }
	
}

class HistoryView: NavigationView {
	
	private var numbersLabel: UILabel?
	
	private lazy var tableview: UITableView = { [weak self] in
		let view = UITableView(frame: .zero, style: .grouped)
		view.backgroundColor = UIColor(white: 1.0, alpha: LayoutPartner.NavigationView().backgroundColorAlpha)
		view.delegate = self
		view.dataSource = self
		view.allowsMultipleSelection = false
		view.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
		view.separatorInset = .zero
		view.separatorStyle = .singleLine
		return view
		}()
	
	private var dataSource: [(time: String, name: String)] = UserPreference.shared.history.files
	private weak var delegate: HistoryViewDelegate? = nil
	
	init(delegate: HistoryViewDelegate?) {
		super.init(frame: .zero)
		self.delegate = delegate
		self.bar.title = "棋 谱 文 件"
		self.bar.rightBarButtonItem?.image = ResourcesProvider.shared.image(named: "delete")
		self.bar.rightBarButtonItem?.addTapTarget(self, action: #selector(self.deleteAll(gesture:)))
		
		// label
		let fontSize = LayoutPartner.NavigationView().smallTitleFontSize
		func createLabel() -> UILabel {
			let label = UILabel()
			label.textColor = UIColor.carbon
			label.font = UIFont.kaitiFont(ofSize: fontSize)
			label.textAlignment = .center
			return label
		}
		
		let label = createLabel()
		self.numbersLabel = label
		self.contentView.addSubview(label)
		label.snp.makeConstraints {
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.top.equalTo(self.contentView).offset(Cell.edge)
			$0.height.equalTo(fontSize + 4.0)
		}
		
		// button
		func createButton(isRed: Bool = false) -> UIButton {
			let button = UIButton()
			button.backgroundColor = isRed ? .red : .white
			button.titleLabel?.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			button.setTitleColor(isRed ? .white : .china, for: .normal)
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
		button.setTitle("载  入", for: .normal)
		button.addTarget(self, action: #selector(self.didClickButton(sender:)), for: .touchUpInside)
		self.contentView.addSubview(button)
		button.snp.makeConstraints {
			$0.left.equalTo(self.contentView)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(line.snp.left)
			$0.height.equalTo(Cell.height)
		}
		
		button = createButton(isRed: true)
		button.tag = 1
		button.setTitle("删  除", for: .normal)
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
		
		self.refreshNumber()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

// MARK: - Private
extension HistoryView {
	
	@objc private func deleteAll(gesture: UIGestureRecognizer) {
		gesture.isEnabled = false
		defer {
			WavHandler.playButtonWav()
			gesture.isEnabled = true
		}

		guard self.dataSource.count > 0 else { return }
		
		let controller = UIAlertController(title: "确定要删除所有棋谱？", message: nil, preferredStyle: .alert)
		controller.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
			self.dataSource.removeAll()
			self.tableview.reloadData()
			self.refreshNumber()
			UserPreference.shared.history.deleteAll()
		}))
		controller.addAction(UIAlertAction(title: "取消", style: .default, handler: { (_) in
		}))
		
		self.delegate?.viewcontroller.present(controller, animated: true, completion: nil)
	}
	
	private func refreshNumber() {
		let index = self.tableview.indexPathForSelectedRow?.row ?? -1
		self.numbersLabel?.text = "文件：\(index + 1) / \(self.dataSource.count)"
	}
	
	@objc private func didClickButton(sender: UIButton) {
		sender.isEnabled = false
		defer {
			sender.isEnabled = true
		}
		
		guard let index = self.tableview.indexPathForSelectedRow?.row else {
			WavHandler.playButtonWav()
			return
		}
		
		let item = self.dataSource[index]
		if sender.tag == 0 {
			self.dismiss()
			let result = UserPreference.shared.history.read(time: item.time)
			self.delegate?.historyView(didLoad: result.file, name: item.name, detail: result.detail)
		} else {
			WavHandler.playButtonWav()
			
			let controller = UIAlertController(title: "确定要删除棋谱\(item.time) \(item.name)？", message: nil, preferredStyle: .alert)
			controller.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
				self.dataSource.remove(at: index)
				self.tableview.delete(indexPaths: [IndexPath(row: index, section: 0)])
				self.refreshNumber()
				UserPreference.shared.history.delete(time: item.time)
			}))
			controller.addAction(UIAlertAction(title: "取消", style: .default, handler: { (_) in
			}))
			
			self.delegate?.viewcontroller.present(controller, animated: true, completion: nil)
		}
	}
	
}

// MARK: - UITableViewDelegate
extension HistoryView: UITableViewDelegate, UITableViewDataSource {
	
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
		cell.reloadCell(with: "\(item.time) \(item.name)")
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		WavHandler.playButtonWav()
		self.refreshNumber()
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
		
		private weak var fileName: UILabel?
		
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			let layout = LayoutPartner.ChessBoard()
			
			let logo = UIImageView()
			logo.image = ResourcesProvider.shared.image(named: "AI")
			self.contentView.addSubview(logo)
			logo.snp.makeConstraints {
				$0.left.equalTo(self.contentView).offset(3.0)
				$0.centerY.equalTo(self.contentView)
				$0.width.equalTo(layout.chessSize)
				$0.height.equalTo(layout.chessSize)
			}
			
			let fileName: UILabel = {
				let label = UILabel()
				label.textColor = UIColor.carbon
				label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
				label.textAlignment = .left
				label.adjustsFontSizeToFitWidth = true
				return label
			}()
			
			self.contentView.addSubview(fileName)
			fileName.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.left.equalTo(logo.snp.right).offset(3.0)
				$0.right.equalTo(self.contentView).offset(-3.0)
			}
			
			self.fileName = fileName
		}
		
		required public init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		public func reloadCell(with fileName: String) {
			self.fileName?.text = fileName
		}
	}
	
}
