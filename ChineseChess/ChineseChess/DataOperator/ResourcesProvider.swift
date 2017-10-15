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
	
	public func image(named: String) -> UIImage? {
		guard let named = self.images[named] else { return nil }
		return UIImage(named: named)
	}
	
	public func wav(named: String) -> AVAudioPlayer? {
		guard let wav = self.wavs[named], let url = Bundle.main.url(forResource: wav.name, withExtension: wav.type) else { return nil }
		return try? AVAudioPlayer(contentsOf: url)
	}
	
	// MARK: - Private
	private let images: [String: String] = ["home": "icon_home", "title": "icon_title", "button": "icon_button"]
	private let wavs: [String: (name: String, type: String)] = ["BGM": ("沧海龙吟", "mp3")]
	
	override private init() {
		super.init()
	}
	
}
