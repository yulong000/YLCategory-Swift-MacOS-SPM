//
//  NSColor+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSColor {
    
    // MARK: - 创建亮色｜暗色模式下的颜色
    convenience init(light: NSColor, dark: NSColor?) {
        if #available(macOS 10.15, *) {
            self.init(name: nil, dynamicProvider: { appearance in
                if appearance.bestMatch(from: [.darkAqua, .vibrantDark]) == .darkAqua ||
                    appearance.bestMatch(from: [.darkAqua, .vibrantDark]) == .vibrantDark {
                    return dark ?? light
                }
                return light
            })
        } else {
            self.init(cgColor: light.cgColor)!
        }
    }
    
    /// 通过16进制字符串，创建color, 创建失败，返回nil
    /// - Parameter hexString: 16进制字符串，`#FFF, #ffffff, FFFF, fff, FFFFFFFF, #ffffffff`
    convenience init?(hexString: String) {
        // 1. 去除 # 和空格
        var cleanHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        // 2. 将 3、4 位扩展为 6、8 位
        if cleanHex.count == 3 || cleanHex.count == 4 {
            cleanHex = cleanHex.map { "\($0)\($0)" }.joined()
        }
        
        // 3. 严格校验长度（仅允许 6 或 8 位）
        guard cleanHex.count == 6 || cleanHex.count == 8 else {
            assert(false, "Invalid hex string length: \(hexString)")
            return nil
        }
        
        // 4. 使用 Scanner 解析 16 进制数值（天然支持大小写，性能更高）
        var hexValue: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&hexValue) else {
            assert(false, "Invalid hex character in string: \(hexString)")
            return nil
        }
        
        let red, green, blue, alpha: CGFloat
        if cleanHex.count == 6 {
            red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
            blue  = CGFloat(hexValue & 0x0000FF)        / 255.0
            alpha = 1.0
        } else {
            red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
            alpha = CGFloat(hexValue & 0x000000FF)        / 255.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 通过16进制字符串，创建NSColor, 创建失败，返回 `.clear`
    /// - Parameter hexString: 颜色字符串，`#FFF, #ffffff, FFFF, fff, FFFFFFFF, #ffffffff`
    /// - Returns: 返回color
    static func hex(_ hexString: String) -> NSColor {
        return NSColor(hexString: hexString) ?? .clear
    }
    
    // MARK: - 返回带有透明度的颜色
    func alpha(_ a: CGFloat) -> NSColor {
        let value = min(max(a, 0), 1)
        let newAlpha = alphaComponent * value
        return withAlphaComponent(newAlpha)
    }
    
    // MARK: - 获取十六进制字符串
    var hexString: String {
        guard let color = usingColorSpace(.sRGB) else { return "#000000" }
        
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        let a = Int(round(alphaComponent * 255))
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
    
    // MARK: 转成16进制字符串 #FFFFFFAA
    var hexStringWithAlpha: String {
        guard let color = usingColorSpace(.sRGB) else { return "#00000000" }
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        let a = Int(round(alphaComponent * 255))
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
    
    // MARK: 转成16进制字符串 #FFFFFF
    var hexStringWithoutAlpha: String {
        guard let color = usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int(round(redComponent * 255))
        let g = Int(round(greenComponent * 255))
        let b = Int(round(blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
