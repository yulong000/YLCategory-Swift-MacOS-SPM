//
//  System.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/7/14.
//


import AppKit
import SystemConfiguration

/// 当前系统版本号
public let System_OS_Version = {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}()
/// 当前登录的用户名, 未登录用户时，返回nil
public var GUIUserName: String? {
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, nil, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    return userName
}
/// 当前登录的用户名(例如/Users/xxx/中的xxx，有可能跟 GUIUserName 不一样), 未登录用户时，返回nil
public var GUIUserDisplayName: String? {
    var uid: uid_t = 0
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, &uid, nil) as? String,
          userName != "loginWindow" else {
        return nil
    }
    guard let pwd = getpwuid(uid),
          let home = pwd.pointee.pw_dir else {
        return nil
    }
    return String(cString: home).components(separatedBy: "/").last
}
/// 当前用户的名字 （/Users/xxx中的xxx）
public var UserName: String { GUIUserDisplayName ?? NSUserName() }
/// 当前用户的目录 （/Users/xxx）
public var UserHome: String {
    var uid: uid_t = 0
    guard let userName = SCDynamicStoreCopyConsoleUser(nil, &uid, nil) as? String,
          userName != "loginWindow",
          let pwd = getpwuid(uid),
          let home = pwd.pointee.pw_dir else {
        return "/Users/\(NSUserName())"
    }
    return String(cString: home)
}


struct User {
    
    static let guiName
}
