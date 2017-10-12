//
//  AppDelegate.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/11.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	lazy var window: UIWindow? = {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.backgroundColor = UIColor.white
		window.rootViewController = HomeVC()
		return window
	}()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		self.window?.makeKeyAndVisible()
		Thread.sleep(forTimeInterval: 1.625)
		return true
	}

	func applicationWillTerminate(_ application: UIApplication) {
		
	}

}

