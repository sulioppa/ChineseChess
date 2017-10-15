//
//  UserPreference.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

class UserPreference: NSObject {

	public static let shared: UserPreference = UserPreference()
	
	public var playBGM: Bool = true
	
	public func savePreference() {
		UserDefaults.standard.set(self.dictionary, forKey: Key.userPreference)
		UserDefaults.standard.synchronize()
	}
	
	// MARK: - Private
	private struct Key {
		public static let userPreference = "ChineseChess"
		public static let playBGM = "playBGM"
	}
	
	override private init() {
		super.init()
		guard let preference = UserDefaults.standard.object(forKey: Key.userPreference) as? [String: Any] else { return }
		self.playBGM <- preference[Key.playBGM]
	}
	
	private var dictionary: [String: Any] {
		return [
			Key.playBGM: self.playBGM
		]
	}
	
}
