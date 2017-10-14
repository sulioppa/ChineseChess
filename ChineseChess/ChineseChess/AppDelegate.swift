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
		window.backgroundColor = UIColor.black
		window.rootViewController = HomeVC()
		return window
	}()

	// MARK: - App Entrance
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// BGM - 沧海龙吟
		BGMManager.invoke(isLaunch: true)
		
		self.window?.makeKeyAndVisible()
		Thread.sleep(forTimeInterval: Macro.Time.launchLastTime)
		return true
	}

	// MARK: - SaveData
	func applicationWillTerminate(_ application: UIApplication) {
		UserPreference.shared.savePreference()
	}

}

