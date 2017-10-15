//
//  BGMHandler.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import AVFoundation

class BGMHandler: NSObject {
	
	private static let bgm = ResourcesProvider.shared.wav(named: "BGM")
	
	public class func invoke(isLaunch: Bool = false) {
		if UserPreference.shared.playBGM {
			self.bgm?.currentTime = isLaunch ? 48.0 : 0.0
			self.bgm?.numberOfLoops = -1
			let audioSession = AVAudioSession.sharedInstance()
			try? audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
			try? audioSession.setActive(true)
			self.bgm?.play()
		} else {
			self.bgm?.stop()
		}
	}
	
}
