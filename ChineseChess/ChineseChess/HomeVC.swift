//
//  HomeVC.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/11.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import SnapKit

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		
		let view = UIView()
		view.backgroundColor = UIColor.yellow
		self.view.addSubview(view)
		view.snp.makeConstraints {
			$0.edges.equalTo(UIEdgeInsetsMake(10, 10, 10, 10))
		}
    }

}
