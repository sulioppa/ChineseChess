//
//  MenuView.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/31.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

protocol MenuViewDelegate: NSObjectProtocol {
	func menuView(_ menuView: NavigationView, didSelectRowAt index: Int)
}

class MenuView: NavigationView, UITableViewDelegate, UITableViewDataSource {

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
	
	public weak var delegate: MenuViewDelegate?
	
	public typealias DataItem = (image: String, title: String, status: String?)
	public var dataSource: [DataItem] = []
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.bar.title = "菜  单"
		self.initRightBarButtonItem()
		
		self.initDataSource()
		self.layoutTableView()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func initDataSource() {
		fatalError("\(#function) should be override in subclass.")
	}
	
	// MARK: - UITableViewDelegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Cell.height / 2.0
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
		cell.setDataItem(item: self.dataSource[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		fatalError("\(#function) should be override in subclass.")
	}
	
}

// MARK: - Function.
extension MenuView {
	
	private func initRightBarButtonItem() {
		let bgm = UserPreference.shared.playBGM
		let image = ResourcesProvider.shared.image(named: "bgm")
		self.bar.rightBarButtonItem?.image = bgm ? image : image?.image(blende: UIColor.white)
		
		self.bar.rightBarButtonItem?.addTapTarget(self, action: #selector(self.didSwitchBGM(sender:)))
	}
	
	@objc private func didSwitchBGM(sender: UIGestureRecognizer?) {
		sender?.isEnabled = false
		defer {
			sender?.isEnabled = true
		}
		
		let bgm = UserPreference.shared.playBGM.reverse()
		let image = ResourcesProvider.shared.image(named: "bgm")
		self.bar.rightBarButtonItem?.image = bgm ? image : image?.image(blende: UIColor.white)
		
		WavHandler.playBGM()
	}
	
	private final func layoutTableView() {
		self.contentView.addSubview(self.tableview)
		self.tableview.snp.makeConstraints {
			$0.top.equalTo(self.contentView)
			$0.left.equalTo(self.contentView).offset(Cell.edge)
			$0.bottom.equalTo(self.contentView)
			$0.right.equalTo(self.contentView).offset(-Cell.edge)
			$0.width.equalTo(Cell.width)
			$0.height.equalTo(Cell.estimatedHeight(rows: self.dataSource.count))
		}
	}
	
	public final func show(delegate: MenuViewDelegate?) {
		self.delegate = delegate
		self.show()
	}
	
}

// MARK: - Cell
extension MenuView {
	
	public class Cell: UITableViewCell {
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
			return Cell.height * CGFloat(rows + 1)
		}
		
		private weak var logo: UIImageView?
		private weak var title: UILabel?
		
		private lazy var status: UILabel = self.label
		private lazy var entrance: UIImageView = UIImageView(image: ResourcesProvider.shared.image(named: "in")?.image(blende: UIColor.china))
		
		private var label: UILabel {
			let label = UILabel()
			label.textColor = UIColor.china
			label.font = UIFont.kaitiFont(ofSize: LayoutPartner.NavigationView().subTitleFontSize)
			label.textAlignment = .center
			return label
		}
		
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.backgroundColor = UIColor.clear
			self.contentView.backgroundColor = UIColor.clear
			
			let logo = UIImageView()
			logo.contentMode = .center
			self.contentView.addSubview(logo)
			logo.snp.makeConstraints {
				$0.left.equalTo(self.contentView).offset(3.0)
				$0.centerY.equalTo(self.contentView)
			}
			
			let title = self.label
			self.contentView.addSubview(title)
			title.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.left.equalTo(logo.snp.right).offset(3.0)
			}
			
			self.entrance.contentMode = .center
			self.contentView.addSubview(self.entrance)
			self.entrance.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.right.equalTo(self.contentView).offset(-3.0)
			}
			
			self.contentView.addSubview(self.status)
			self.status.snp.makeConstraints {
				$0.centerY.equalTo(self.contentView)
				$0.centerX.equalTo(self.entrance.snp.centerX)
			}
			
			self.logo = logo
			self.title = title
		}
		
		required public init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		public func setDataItem(item: DataItem) {
			self.logo?.image = ResourcesProvider.shared.image(named: item.image)?.image(blende: UIColor.china)
			self.title?.text = item.title
			
			if let status = item.status {
				self.status.text = status
				self.status.isHidden = false
				self.entrance.isHidden = true
			} else {
				self.status.isHidden = true
				self.entrance.isHidden = false
			}
		}
	}
	
}
