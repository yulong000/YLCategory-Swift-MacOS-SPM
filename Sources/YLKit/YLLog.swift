//
//  YLLog.swift
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2024/12/3.
//

import Foundation
import Carbon
import Cocoa
import os

public enum __YLLogStyle {
    
    case `default`
    case success
    case failure
    case warning
    case flag
    case number(Int)
    case emoji(String)
    
    var symbol: String {
        switch self {
        case .`default`:        return ""
        case .success:          return "✅"
        case .failure:          return "❌"
        case .warning:          return "⚠️"
        case .flag:             return "🚩"
        case .emoji(let e):     return e
        case .number(let n):
            let numbers = ["0️⃣", "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟"]
            return (0...10).contains(n) ? numbers[n] : "🔢"
        }
    }
}

public var YL_LOG_MORE: Bool = false // 是否可以打印更详细的信息
public var YL_LOG_RELEASE: Bool = false // 打包时是否打印

public func YLLog(_ items: Any..., style: __YLLogStyle = .default, file: NSString = #file, function: String = #function, line: Int = #line) {
#if !DEBUG
    guard YL_LOG_RELEASE else { return }
#endif
    var message: String = ""
    let formatItems = items.map { YLLogFormat($0) }
    message = formatItems.joined(separator: "👈\n") + (formatItems.count > 1 ? "👈" : "")
    if !style.symbol.isEmpty {
        message = "\(style.symbol) \(message)"
    }
    if #available(macOS 26.0, *) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? App_Name, category: "YLLog")
        if YL_LOG_MORE {
            os_log("%{public}@\n👉 [ %{public}@ 第%{public}d行 ] in %{public}@", log: log, type: .default, message, function, line, file.lastPathComponent)
        } else {
            os_log("%{public}@", log: log, type: .default, message)
        }
    } else {
        if YL_LOG_MORE {
            NSLog("%@\n👉 [ %@ 第%d行 ] in %@", message, function, line, file.lastPathComponent)
        } else {
            NSLog("%@", message)
        }
    }
}

open class __YLLog {
    
    public static let shared = __YLLog()
    private init() {}
    
    private var localMonitor: Any?
    private var globalMonitor: Any?
    
    // MARK: 监听按键
    open func addKeyMonitor() {
        if localMonitor == nil {
            localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                let flags: NSEvent.ModifierFlags = [.control, .shift, .command, .option]
                if event.keyCode == kVK_ANSI_P && event.modifierFlags.intersection(flags) == flags {
                    YL_LOG_RELEASE.toggle()
                }
                if event.keyCode == kVK_ANSI_M && event.modifierFlags.intersection(flags) == flags {
                    YL_LOG_MORE.toggle()
                }
                return event
            }
        }
        if globalMonitor == nil {
            globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                let flags: NSEvent.ModifierFlags = [.control, .shift, .command, .option]
                if event.keyCode == kVK_ANSI_P && event.modifierFlags.intersection(flags) == flags {
                    YL_LOG_RELEASE.toggle()
                }
                if event.keyCode == kVK_ANSI_M && event.modifierFlags.intersection(flags) == flags {
                    YL_LOG_MORE.toggle()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [self] in
            removeKeyMonitor()
        }
    }
    
    private func removeKeyMonitor() {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }
}

/// 优先使用 JSON 格式化，保留中文，并固定字典字段顺序。
fileprivate func YLLogJSON(_ value: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(value),
          let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]) else { return nil }
    return String(data: data, encoding: .utf8)
}

/// 用 JSON 编码处理引号、反斜杠和控制字符，中文保持可读。
fileprivate func YLLogQuoted(_ string: String) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: [string]),
          let json = String(data: data, encoding: .utf8) else {
        return "\"\(string)\""
    }
    return String(json.dropFirst().dropLast())
}

fileprivate func YLLogFormat(_ value: Any, indentLevel: Int = 0, nested: Bool = false) -> String {
    let indent = String(repeating: "  ", count: indentLevel)
    let childIndent = indent + "  "

    if let data = value as? Data {
        let content: String
        if let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) {
            content = YLLogFormat(object, indentLevel: indentLevel, nested: true)
        } else {
            content = String(data: data, encoding: .utf8) ?? String(describing: data)
        }
        return "DATA:【 \(content) 】"
    }
    if let dictionary = value as? [AnyHashable: Any] {
        if let json = YLLogJSON(dictionary) {
            return json.replacingOccurrences(of: "\n", with: "\n" + indent)
        }
        // Date、URL、Data 或非字符串键等不能直接转 JSON 时，递归格式化。
        let entries = dictionary.map { (String(describing: $0.key), $0.value) }
            .sorted { $0.0 < $1.0 }
            .map { key, item in
                childIndent + YLLogQuoted(key) + ": " + YLLogFormat(item, indentLevel: indentLevel + 1, nested: true)
            }
        return entries.isEmpty ? "{}" : "{\n" + entries.joined(separator: ",\n") + "\n" + indent + "}"
    }
    if let array = value as? [Any] {
        if let json = YLLogJSON(array) {
            return json.replacingOccurrences(of: "\n", with: "\n" + indent)
        }
        let entries = array.map {
            childIndent + YLLogFormat($0, indentLevel: indentLevel + 1, nested: true)
        }
        return entries.isEmpty ? "[]" : "[\n" + entries.joined(separator: ",\n") + "\n" + indent + "]"
    }
    if value is NSNull { return "null" }
    if let string = value as? String {
        return nested ? YLLogQuoted(string) : string
    }
    // 通过 JSON 保留 NSNumber 的数字/布尔类型，避免把数字 1 打印为 true。
    if let number = value as? NSNumber,
       let data = try? JSONSerialization.data(withJSONObject: [number]),
       let json = String(data: data, encoding: .utf8) {
        return String(json.dropFirst().dropLast())
    }
    return String(describing: value)
}
