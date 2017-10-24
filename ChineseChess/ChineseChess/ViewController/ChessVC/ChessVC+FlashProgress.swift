//
//  ChessVC+FlashProgress.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/10/24.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

// MAKR: - Think Animation
extension ChessVC {
	
	public final func setFlashProgress(progress: Float) {
		guard progress >= 0.0 && progress <= 1.0 else { return }
		self.progressLayer?.path = FlashLayerController.rect(progress: progress)
	}
	
}
