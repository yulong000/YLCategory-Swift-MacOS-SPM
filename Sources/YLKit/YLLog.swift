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

/// 为无法反射的对象或需要控制日志字段的模型提供自定义内容。
public protocol YLLogRepresentable {
    var ylLogRepresentation: Any { get }
}

/// 格式化任意值；最多展开 12 层，并标记循环引用。输出用于日志，不保证是合法 JSON。
public func YLPrettyPrinted(_ value: Any) -> String {
    YLLogFormatter().format(value)
}

public extension Array {
    var prettyPrinted: String { YLPrettyPrinted(self) }
}

public extension Dictionary {
    var prettyPrinted: String { YLPrettyPrinted(self) }
}

public extension Set {
    var prettyPrinted: String { YLPrettyPrinted(self) }
}

public extension Data {
    var prettyPrinted: String { YLPrettyPrinted(self) }
}

public extension NSObject {
    var prettyPrinted: String { YLPrettyPrinted(self) }
}

fileprivate func YLLogFormat(_ value: Any) -> String {
    YLPrettyPrinted(value)
}

fileprivate func YLLogQuoted(_ string: String) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: [string]),
          let json = String(data: data, encoding: .utf8) else { return "\"\(string)\"" }
    return String(json.dropFirst().dropLast())
}

fileprivate final class YLLogFormatter {
    private var activeObjects = Set<ObjectIdentifier>()

    func format(_ value: Any, depth: Int = 0, nested: Bool = false) -> String {
        guard depth < 12 else { return "<最大展开深度>" }
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            guard let wrapped = mirror.children.first else { return "nil" }
            return format(wrapped.value, depth: depth, nested: nested)
        }
        if value is NSNull { return "null" }
        if let string = value as? String { return nested ? YLLogQuoted(string) : string }
        if let number = value as? NSNumber,
           let data = try? JSONSerialization.data(withJSONObject: [number]),
           let json = String(data: data, encoding: .utf8) {
            return String(json.dropFirst().dropLast())
        }
        if let date = value as? Date { return String(describing: date) }
        if let url = value as? URL { return nested ? YLLogQuoted(url.absoluteString) : url.absoluteString }
        if let data = value as? Data {
            if let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) {
                return "DATA:【 " + format(object, depth: depth + 1, nested: true) + " 】"
            }
            return "DATA:【 " + (String(data: data, encoding: .utf8) ?? String(describing: data)) + " 】"
        }

        // 在集合桥接或自定义内容展开前检测对象，避免互相引用时无限递归。
        var identity: ObjectIdentifier?
        if mirror.displayStyle == .class {
            let id = ObjectIdentifier(value as AnyObject)
            guard activeObjects.insert(id).inserted else {
                return "<循环引用: \(String(describing: type(of: value)))>"
            }
            identity = id
        }
        defer {
            if let identity { activeObjects.remove(identity) }
        }
        if let custom = value as? YLLogRepresentable {
            return format(custom.ylLogRepresentation, depth: depth + 1, nested: nested)
        }

        let indent = String(repeating: "  ", count: depth)
        let childIndent = indent + "  "
        func container(_ entries: [String], open: String, close: String) -> String {
            entries.isEmpty ? open + close
                : open + "\n" + entries.map { childIndent + $0 }.joined(separator: ",\n") + "\n" + indent + close
        }
        if let dictionary = value as? [AnyHashable: Any] {
            let entries = dictionary.map { (String(describing: $0.key), $0.value) }
                .sorted { $0.0 < $1.0 }
                .map { YLLogQuoted($0.0) + ": " + format($0.1, depth: depth + 1, nested: true) }
            return container(entries, open: "{", close: "}")
        }
        if let array = value as? [Any] {
            return container(array.map { format($0, depth: depth + 1, nested: true) }, open: "[", close: "]")
        }
        if mirror.displayStyle == .set {
            let entries = mirror.children.map { format($0.value, depth: depth + 1, nested: true) }.sorted()
            return container(entries, open: "[", close: "]")
        }
        if mirror.displayStyle == .class || mirror.displayStyle == .struct {
            var fields: [String] = []
            var current: Mirror? = mirror
            while let reflected = current {
                fields += reflected.children.map {
                    YLLogQuoted($0.label ?? "?") + ": " + format($0.value, depth: depth + 1, nested: true)
                }
                current = reflected.superclassMirror
            }
            if !fields.isEmpty {
                return String(describing: type(of: value)) + " " + container(fields, open: "{", close: "}")
            }
        }
        return String(describing: value)
    }
}
