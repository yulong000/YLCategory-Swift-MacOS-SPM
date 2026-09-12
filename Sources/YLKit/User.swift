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
    public static var name: String { home.components(separatedBy: "/").last ?? NSUserName() }
    /// 访达中的用户目录 /Users/xxx）
    public static var home: String {
        var uid = getuid()
        
        if let userName = SCDynamicStoreCopyConsoleUser(nil, &uid, nil) as String?,
           !userName.isEmpty,
           userName.lowercased() != "loginwindow" {
            // 使用桌面登录用户的uid
        } else {
            uid = getuid()
        }
        
        guard let pwd = getpwuid(uid),
              let home = pwd.pointee.pw_dir else {
            return NSHomeDirectory()
        }
        return String(cString: home)
    }
    /// 全名（登录时显示的名字）
    public static var fullName: String { NSFullUserName() }
    /// 登录名（活动监视器中的用户名）
    public static var loginName: String { NSUserName() }
    /// 是否是用户登录窗口
    public static var isLoginWindow: Bool {
        guard let userName = SCDynamicStoreCopyConsoleUser(nil, nil, nil) as? String else {
            return true
        }
        return userName.lowercased() == "loginwindow"
    }
}
