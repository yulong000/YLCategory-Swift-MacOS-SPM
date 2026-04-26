//
//  YLTheme.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/1/20.
//

import AppKit

// 应用语言类型枚举
@objc public enum ThemeType: Int {
    case auto       // 自动
    case light      // 亮色
    case dark       // 暗色
    
    public func title() -> String {
        switch self {
        case .auto:     return YLTheme.localize("Auto")
        case .light:    return YLTheme.localize("Light")
        case .dark:     return YLTheme.localize("Dark")
        }
    }
}

public class YLTheme {
    
    /// 所有的主题
    public class var allThemeTitles: [String] {
        [
            ThemeType.auto.title(),
            ThemeType.light.title(),
            ThemeType.dark.title()
        ]
    }
    
    /// 根据标题获取主题类型
    public class func type(with title: String) -> ThemeType {
        switch title {
        case YLTheme.localize("Auto"):          return .auto
        case YLTheme.localize("Light"):         return .light
        case YLTheme.localize("Dark"):          return .dark
        default:                                return .auto
        }
    }
    
    // MARK: 设置主题
    public class func set(theme type: ThemeType) {
        switch type {
        case .auto:     NSApp.appearance = nil
        case .light:    NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:     NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
    
    public static func localize(_ key: String) -> String { NSLocalizedString(key, bundle: .module, comment: "") }
}
