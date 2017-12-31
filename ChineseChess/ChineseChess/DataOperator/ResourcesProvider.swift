//
//  ResourcesProvider.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/13.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import AVFoundation

class ResourcesProvider: NSObject {

	public static let shared: ResourcesProvider = ResourcesProvider()
	
	override private init() {
		super.init()
	}
	
	// MARK: - Private
	private let images: [String: String] = [
		"home": "icon_home",
		"title": "icon_title",
		"button": "icon_button",
		"close": "icon_close",
		"loading": "icon_loading",
		"board": "board_chess",
		"wood": "board_wood",
		"AI": "icon_thinking",
		"帥": "chess_0",
		"將": "chess_7",
		"prompt": "icon_prompt",
		"back": "icon_back",
		"in": "icon_in",
		"tips": "icon_tips",
		"bgm": "icon_bgm",
		"reverse": "icon_reverse",
		"opposite": "icon_opposite",
		"put": "icon_put",
		"history": "icon_history"
	]
	
	private let chess: [String?] = [
		nil, "chess_15", "chess_14", "chess_16", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
		"chess_0",
		"chess_1", "chess_1",
		"chess_2", "chess_2",
		"chess_3", "chess_3",
		"chess_4", "chess_4",
		"chess_5", "chess_5",
		"chess_6", "chess_6", "chess_6", "chess_6", "chess_6",
		"chess_7",
		"chess_8", "chess_8",
		"chess_9", "chess_9",
		"chess_10", "chess_10",
		"chess_11", "chess_11",
		"chess_12", "chess_12",
		"chess_13", "chess_13", "chess_13", "chess_13", "chess_13"
	]
	
	private let wavs: [String: (name: String, type: String)] = [
		"BGM": ("沧海龙吟", "mp3"),
		"check": ("check", "wav"),
		"eat": ("eat", "wav"),
		"run": ("run", "wav"),
		"select": ("select", "wav"),
		"mate": ("mate", "m4a")
	]
	
	private var wavsCache: [String: AVAudioPlayer] = [:]
}

// MARK: - Public
extension ResourcesProvider {
	
	public func image(named: String) -> UIImage? {
		guard let named = self.images[named] else { return nil }
		return UIImage(named: named)
	}
	
	public func chess(index: Int) -> UIImage? {
		guard let name = self.chess[index] else { return nil }
		return UIImage(named: name)
	}
	
	public func wav(named: String) -> AVAudioPlayer? {
		guard let wav = self.wavs[named], let url = Bundle.main.url(forResource: wav.name, withExtension: wav.type) else { return nil }
		
		if let player = self.wavsCache[named] {
			return player
		} else {
			self.wavsCache[named] = try? AVAudioPlayer(contentsOf: url)
			return self.wavsCache[named]
		}
	}
	
	public func bundle(named: String, type: String) -> Data? {
		guard let url = Bundle.main.url(forResource: named, withExtension: type) else { return nil }
		
		return try? Data(contentsOf: url)
	}
	
}
