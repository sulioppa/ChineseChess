//
//  UserFileHandler.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/6.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit

class UserFileHandler: NSObject {

	private static let directory: String = {
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
		let directory = "\(path)/History"
		
		if !FileManager.default.fileExists(atPath: directory) {
			try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
		}
		return directory
	}()
	
	private class func url(name: String) -> URL? {
		return URL(string: "\(self.directory)/\(name)")
	}
	
	public class func readFile(name: String) -> Data? {
		return FileManager.default.contents(atPath: "\(self.directory)/\(name)")
	}

	public class func writeFile(name: String, data: Data?) {
		guard let url = self.url(name: name) else { return }
		try? data?.write(to: url)
	}
	
	public class func deleteFile(name: String) {
		guard let url = self.url(name: name) else { return }
		try? FileManager.default.removeItem(at: url)
	}
	
}
