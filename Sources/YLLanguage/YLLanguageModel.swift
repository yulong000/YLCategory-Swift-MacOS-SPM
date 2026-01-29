//
//  YLLanguageModel.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

public class YLLanguageModel {
    
    public var languageType: LanguageType
    public var code: String = ""
    public var title: String = ""
    
    init(type: LanguageType) {
        languageType = type
        switch type {
        case .system:
            code = ""
            title = YLLanguage.localize("Follow System")
        case .chineseSimplified:
            code = "zh-Hans"
            title = "🇨🇳 简体中文"
        case .chineseTraditional:
            code = "zh-Hant"
            title = "🇭🇰 繁體中文"
        case .english:
            code = "en"
            title = "🇬🇧 English"
        case .japanese:
            code = "ja"
            title = "🇯🇵 日本語"
        case .korean:
            code = "ko"
            title = "🇰🇷 한국어"
        case .spanish:
            code = "es"
            title = "🇪🇸 Español"
        case .french:
            code = "fr"
            title = "🇫🇷 Français"
        case .portuguese:
            code = "pt-PT"
            title = "🇵🇹 Português"
        case .german:
            code = "de"
            title = "🇩🇪 Deutsch"
        }
    }
}
