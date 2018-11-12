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
	
	// Properties
	public var playBGM: Bool = true
	public let game: Game = Game()
	public let history: History = History()
	public let multiPeer: MultiPeer = MultiPeer()
	
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
	
	public func savePreference() {
		UserDefaults.standard.set(self.dictionary, forKey: Key().userPreference)
		UserDefaults.standard.synchronize()
	}
}

// MARK: - Game
extension UserPreference {
	public class Game {
		public var red: Level = .player
		public var black: Level = .rookie
		public var prompt: Level = .supermaster
		public var record: String = ""
		public var reverse: Bool = false
		public var opposite: Bool = false
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.red: self.red.rawValue,
				key.black: self.black.rawValue,
				key.prompt: self.prompt.rawValue,
				key.record: self.record,
				key.reverse: self.reverse,
				key.opposite: self.opposite
			]
		}
		
		public static func <-(left: Game, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.red <- dictionary[key.red]
			left.black <- dictionary[key.black]
			left.prompt <- dictionary[key.prompt]
			left.record <- dictionary[key.record]
			left.reverse <- dictionary[key.reverse]
			left.opposite <- dictionary[key.opposite]
		}
	}

	public enum Level: Int {
		case player = 0
		case white = 4
		case rookie = 5
		case sprog = 6
		case accidence = 7
		case primary = 8
		case intermediate = 9
		case senior = 11
		case master = 13
		case supermaster = 14
		
		public var isPlayer: Bool {
			return self == .player
		}
		
		public var description: String {
			switch self {
			case .player:
				return "棋 手"
			case .white:
				return "小 白"
			case .rookie:
				return "菜 鸟"
			case .sprog:
				return "新 手"
			case .accidence:
				return "入 门"
			case .primary:
				return "初 级"
			case .intermediate:
				return "中 级"
			case .senior:
				return "高 级"
			case .master:
				return "大 师"
			case .supermaster:
				return "特 级 大 师"
			}
		}
		
		public var name: String {
			return self.description.noSpace
		}
		
		public static func <-(left: inout Level, right: Any?) {
			guard let rawValue = right as? Int else { return }
			left = Level(rawValue: rawValue) ?? .player
		}
		
		public static var levels: [Level] {
			return [ .player, .white, .rookie, .sprog, .accidence, .primary, .intermediate, .senior, .master, .supermaster ]
		}
	}
}

// MARK: - History
extension UserPreference {
	public class History {
		public var reverse: Bool = false
		public var opposite: Bool = false
		
		public var record: String = ""
		public var name: String = "开局"
        public var detail: String = "状态：暂无信息"
		public var result: String = "结果: 未知"
		public var index: Int = -1
		
		private var id: UInt64 = 0
		private var histories: [String: [String]] = [:]
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.reverse: self.reverse,
				key.opposite: self.opposite,
				key.record: self.record,
				key.name: self.name,
				key.detail: self.detail,
				key.result: self.result,
				key.index: self.index,
				key.id: self.id,
				key.histories: self.histories
			]
		}
		
		public static func <-(left: History, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.reverse <- dictionary[key.reverse]
			left.opposite <- dictionary[key.opposite]
			left.record <- dictionary[key.record]
			left.name <- dictionary[key.name]
			left.detail <- dictionary[key.detail]
			left.result <- dictionary[key.result]
			left.index <- dictionary[key.index]
			left.id <- dictionary[key.id]
			left.histories <- dictionary[key.histories]
		}
		
		public final func read(time: String) -> (file: String, detail: String) {
			guard let data = UserFileHandler.read(name: self.histories[time]?.first) else { return ("", "") }
			return (String(data: data, encoding: .utf8) ?? "", self.histories[time]?.last ?? "")
		}
		
		public final func save(time: String, name: String, description: String, file: String) {
			self.histories[time] = ["\(self.id)", name, description]
			self.id += 1
			
			UserFileHandler.write(name: self.histories[time]?.first, data: file.data(using: .utf8))
		}
		
		public final func delete(time: String) {
			UserFileHandler.delete(name: self.histories[time]?.first)
			self.histories.removeValue(forKey: time)
		}
		
		public final func deleteAll() {
			for (_, value) in self.histories {
				UserFileHandler.delete(name: value.first)
			}
			
			self.histories.removeAll()
		}
		
		public var files: [(time: String, name: String)] {
			let files = self.histories.sorted { (a, b) -> Bool in
				guard let timeA = UInt64(a.value[0]), let timeB = UInt64(b.value[0]) else { return false }
				return  timeA > timeB
			}
			
			return files.map({ (record) -> (String, String) in
				return (record.key, record.value[1])
			})
		}
	}
}

// MARK: - MultiPeer
extension UserPreference {
	public class MultiPeer {
		public var nickname: String = "沧海龙吟"
		public var record: String = ""
		public var red: Bool = true
		
		public var rivalname: String {
			return "榣山遗韵"
		}
		
		public var dictionary: [String: Any] {
			let key = Key()
			return [
				key.nickname: self.nickname,
				key.record: self.record,
				key.red: self.red
			]
		}
		
		public static func <-(left: MultiPeer, right: Any?) {
			guard let dictionary = right as? [String: Any] else { return }
			let key = Key()
			left.nickname <- dictionary[key.nickname]
			left.record <- dictionary[key.record]
			left.red <- dictionary[key.red]
		}
	}
}

// MARK: - Key
extension UserPreference {
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
		public let prompt = "prompt"
		public let nickname = "nickname"
		public let histories = "histories"
		public let id = "uuid"
		public let record = "record"
		public let name = "name"
		public let detail = "detail"
		public let index = "index"
		public let result = "result"
	}
}
