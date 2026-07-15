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
    let formatItems = items.map { item -> String in
        if let dict = item as? [AnyHashable: Any] {
            return dict.format()
        }
        if let arr = item as? [Any] {
            return arr.format()
        }
        if let data = item as? Data {
            return data.format()
        }
        return "\(item)"
    }
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
    
    public static var shared = __YLLog()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
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


fileprivate extension Array {

    func format(with indentLevel: UInt8 = 0) -> String {
        // 最终输出的内容
        var desc: String = "[\n"
        // tab对齐
        var tab: String = ""
        for _ in 0..<indentLevel {
            tab.append("\t")
        }
        for obj in self {
            var valStr = "\(tab)\t"
            if let temp = obj as? [AnyHashable: Any] {
                // dict
                valStr += temp.format(with: indentLevel + 1)
            } else if let temp = obj as? [Any] {
                // array
                valStr += temp.format(with: indentLevel + 1)
            } else if let temp = obj as? Bool {
                // bool
                valStr += temp ? "true" : "false"
            } else if let temp = obj as? Data {
                // data
                valStr += temp.format()
            } else {
                valStr += "\(obj)"
            }
            valStr.append(",\n")
            desc.append(valStr)
        }
        // 去掉最后一个,号
        if let range = desc.range(of: ",", options: .backwards) {
            desc.replaceSubrange(range, with: "")
        }
        desc.append("\(tab)]")
        return desc
    }
}

fileprivate extension Dictionary {

    func format(with indentLevel: UInt8 = 0) -> String {
        
        // 最终输出的内容
        var desc: String = "{\n"
        // tab对齐
        var tab: String = ""
        for _ in 0..<indentLevel {
            tab.append("\t")
        }
        
        for k in keys {
            let obj = self[k]
            var key = "\(k)"
            if key.count > 0 {
                key = "\"\(key)\""
            }
            let keyStr = "\(tab)\t\(key): "
            var valStr = ""
            if let temp = obj as? String {
                // 字符串
                valStr = "\"\(temp)\""
            } else if let temp = obj as? Bool {
                // bool
                valStr = temp ? "true" : "false"
            } else if let temp = obj as? [AnyHashable: Any] {
                // dict
                valStr = temp.format(with: indentLevel + 1)
            } else if let temp = obj as? [Any] {
                // array
                valStr = temp.format(with: indentLevel + 1)
            } else if let temp = obj as? Data {
                // data
                valStr = temp.format()
            } else if let temp = obj {
                valStr = "\(temp)"
            } else {
                valStr = "nil"
            }
            valStr += ",\n"
            desc.append(keyStr + valStr)
        }
        // 去掉最后一个,号
        if let range = desc.range(of: ",", options: .backwards) {
            desc.replaceSubrange(range, with: "")
        }
        desc.append("\(tab)}")
        return desc
    }
}

fileprivate extension Data {
    func format() -> String {
        do {
            let result = try JSONSerialization.jsonObject(with: self, options: [])
            if let arr = result as? Array<Any> {
                var str = arr.format()
                str = str.replacingOccurrences(of: "\t", with: "")
                str = str.replacingOccurrences(of: "\n", with: " ")
                return "DATA:【 \(str) 】"
            }
            if let dict = result as? [AnyHashable: Any] {
                var str = dict.format()
                str = str.replacingOccurrences(of: "\t", with: "")
                str = str.replacingOccurrences(of: "\n", with: " ")
                return "DATA:【 \(str)) 】"
            }
        } catch {
            if let str = String(data: self, encoding: .utf8) {
                return "DATA:【 \(str) 】"
            }
        }
        return "\(self)"
    }
}
