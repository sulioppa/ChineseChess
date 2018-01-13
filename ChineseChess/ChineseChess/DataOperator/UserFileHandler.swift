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
		let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
		let directory = "\(document)/User"
		
		if !FileManager.default.fileExists(atPath: directory) {
			try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
		}
		return directory
	}()
	
	private class func url(_ name: String?) -> URL? {
		guard let name = name else { return nil }
		return URL(string: "\(self.directory)/\(name)")
	}
	
	public class func read(name: String?) -> Data? {
		guard let url = self.url(name) else { return nil }
		return FileManager.default.contents(atPath: url.absoluteString)
	}

	public class func write(name: String?, data: Data?) {
		guard let url = self.url(name) else { return }
		try? data?.write(to: url)
	}
	
	public class func delete(name: String?) {
		guard let url = self.url(name) else { return }
		try? FileManager.default.removeItem(at: url)
	}
	
}
