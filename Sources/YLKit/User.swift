//
//  User.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/7/14.
//


import AppKit
import SystemConfiguration

public struct User {
    
    /// 访达中显示的用户名 （/Users/xxx中的xxx）
    public static let name: String = { home.components(separatedBy: "/").last ?? NSUserName() }()
    /// 访达中的用户目录 /Users/xxx）
    public static let home: String = {
        guard let pwd = getpwuid(getuid()),
              let home = pwd.pointee.pw_dir else {
            return "/Users/\(NSUserName())"
        }
        return String(cString: home)
    }()
    /// 全名（登录时显示的名字）
    public static let fullName: String = NSFullUserName()
    /// 登录名（活动监视器中的用户名）
    public static let loginName: String = NSUserName()
    
}
