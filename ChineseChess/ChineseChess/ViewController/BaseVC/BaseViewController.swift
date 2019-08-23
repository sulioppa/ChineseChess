//
//  BaseViewController.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2019/8/16.
//  Copyright © 2019 StarLab. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.modalPresentationStyle = .fullScreen
    }
    
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
