//
//  Dictionary+Json.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/23.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

extension Dictionary {
	
	public var data: Data? {
		return try? JSONSerialization.data(withJSONObject: self, options: .default)
	}
	
	public static func dictionary(from data: Data?) -> [String: Any]? {
		guard let data = data else { return nil }
		
		let obj = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
		return obj as? [String: Any]
	}
	
}

// MARK: - JSONSerialization.WritingOptions
extension JSONSerialization.WritingOptions {
	
	public static let `default`: JSONSerialization.WritingOptions = {
		return JSONSerialization.WritingOptions(rawValue: 0)
	}()

}
