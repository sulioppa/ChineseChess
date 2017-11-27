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
	
	public class Game {
		public var red: Bool = true
		public var black: Bool = true
		public var reverse: Bool = false
		public var opposite: Bool = false
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.red: self.red,
				key.black: self.black,
				key.reverse: self.reverse,
				key.opposite: self.opposite
			]
		}
		
		public static func <-(left: Game, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.red <- dictionary[key.red]
			left.black <- dictionary[key.black]
			left.reverse <- dictionary[key.reverse]
			left.opposite <- dictionary[key.opposite]
		}
	}
	
	public class History {
		public var reverse: Bool = false
		public var opposite: Bool = false
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.reverse: self.reverse,
				key.opposite: self.opposite
			]
		}
		
		public static func <-(left: History, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.reverse <- dictionary[key.reverse]
			left.opposite <- dictionary[key.opposite]
		}
	}
	
	public class MultiPeer {
		public var nickname: String = "沧海龙吟"
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.nickname: self.nickname,
			]
		}
		
		public static func <-(left: MultiPeer, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.nickname <- dictionary[key.nickname]
		}
	}

	public let game: Game = Game()
	public let history: History = History()
	public let multiPeer: MultiPeer = MultiPeer()
	
	public func savePreference() {
		UserDefaults.standard.set(self.dictionary, forKey: Key().userPreference)
		UserDefaults.standard.synchronize()
	}

	// MARK: - Private
	private struct Key {
		public let userPreference = "ChineseChess"
		public let playBGM = "playBGM"
		public let game = "game"
		public let history = "history"
		public let multiPeer = "multiPeer"
		public let reverse = "reverse"
		public let opposite = "opposite"
		public let red = "red"
		public let black = "black"
		public let nickname = "nickname"
	}
	
	override private init() {
		super.init()
		let key: Key = Key()
		guard let preference = UserDefaults.standard.object(forKey: key.userPreference) as? [String: Any] else { return }
		self.playBGM <- preference[key.playBGM]
		self.game <- preference[key.game]
		self.history <- preference[key.history]
		self.multiPeer <- preference[key.multiPeer]
	}
	
	private var dictionary: [String: Any] {
		let key: Key = Key()
		return [
			key.playBGM: self.playBGM,
			key.game: self.game.dictionary,
			key.history: self.history.dictionary,
			key.multiPeer: self.multiPeer.dictionary
		]
	}
}
