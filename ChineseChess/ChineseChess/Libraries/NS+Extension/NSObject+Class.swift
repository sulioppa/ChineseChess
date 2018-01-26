//
//  NSObject+Class.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2017/12/15.
//  Copyright © 2017年 StarLab. All rights reserved.
//

import UIKit

extension NSObject {
	
	public class func instance(from string: String) -> Any? {
		return (NSClassFromString("\(Macro.Project.name).\(string)") as? NSObject.Type)?.init()
	}
	
}
