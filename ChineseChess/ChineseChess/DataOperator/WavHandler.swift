//
//  WavHandler.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/14.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit
import AVFoundation

class WavHandler: NSObject {
	
	private static let bgm = ResourcesProvider.shared.wav(named: "BGM")
	
	public class func playBGM(isLaunch: Bool = false) {
		if UserPreference.shared.playBGM {
			self.bgm?.currentTime = isLaunch ? 48.0 : 0.0
			self.bgm?.numberOfLoops = -1
			let audioSession = AVAudioSession.sharedInstance()
			try? audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
			try? audioSession.setActive(true)
			self.bgm?.play()
		} else {
			self.bgm?.stop()
			let audioSession = AVAudioSession.sharedInstance()
			try? audioSession.setCategory(AVAudioSessionCategoryAmbient)
			try? audioSession.setActive(true)
		}
	}
	
	public class func playButtonWav() {
		AudioServicesPlaySystemSound(1105)
	}
	
	private static var wav: AVAudioPlayer? = nil
	
	private class func playWav(named: String) {
		self.wav = ResourcesProvider.shared.wav(named: named)
		self.wav?.numberOfLoops = 0
		self.wav?.play()
	}
	
	public class func playVoice(state: LunaMoveState) {
		switch state {
		case .select:
			self.playWav(named: "select")
		case .normal:
			self.playWav(named: "run")
		case .eat:
			self.playWav(named: "eat")
		case .check:
			self.playWav(named: "check")
		case .checkMate:
			self.playWav(named: "mate")
		case .eatCheck:
			self.playWav(named: "eat")
			self.playWav(named: "check")
		case .eatCheckMate:
			self.playWav(named: "eat")
			self.playWav(named: "mate")
		}
	}
	
}
