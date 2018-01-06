//
//  UITableView+Update.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/4.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

extension UITableView {
	
	public func insert(indexPaths: [IndexPath]) {
		guard indexPaths.count > 0 else { return }
		
		self.beginUpdates()
		self.insertRows(at: indexPaths, with: .automatic)
		self.endUpdates()
	}
	
	public func delete(indexPaths: [IndexPath]) {
		guard indexPaths.count > 0 else { return }
		
		self.beginUpdates()
		self.deleteRows(at: indexPaths, with: .automatic)
		self.endUpdates()
	}
	
}
