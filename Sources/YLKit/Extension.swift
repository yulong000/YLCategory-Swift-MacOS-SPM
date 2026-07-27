//
//  Extension.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/1/7.
//

import Foundation

public extension Dictionary where Key == String {
    
    /// 读取`Bool`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func boolValue(_ key: String, default value: Bool = false) -> Bool {
        return bool(key) ?? value
    }
    
    /// 读取`Bool？`值
    /// - Parameter key: key值
    /// - Returns: 返回值
    func bool(_ key: String) -> Bool? {
        if let v = self[key] as? Bool { return v }
        if let v = self[key] as? NSNumber { return v.boolValue }
        if let v = self[key] as? Int { return v != 0 }
        if let v = self[key] as? String {
            return v == "1" || v.lowercased() == "true" || v.lowercased() == "yes"
        }
        return nil
    }
    
    /// 读取`String`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func stringValue(_ key: String, default value: String = "") -> String {
        return string(key) ?? value
    }
    
    /// 读取`String?`值
    /// - Parameter key: key值
    /// - Returns: 返回值
    func string(_ key: String) -> String? {
        if let v = self[key] as? String { return v }
        if let v = self[key] as? NSNumber { return v.stringValue }
        if let v = self[key] as? Int { return String(v) }
        if let v = self[key] as? Double { return String(v) }
        if let v = self[key] as? Bool { return v ? "true" : "false" }
        if let v = self[key] as? Data { return String(data: v, encoding: .utf8) }
        return nil
    }
    
    /// 读取`Int`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func intValue(_ key: String, default value: Int = 0) -> Int {
        return int(key) ?? value
    }
    
    /// 读取`Int?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func int(_ key: String) -> Int? {
        if let v = self[key] as? Int { return v }
        if let v = self[key] as? NSNumber { return v.intValue }
        if let v = self[key] as? Double { return Int(v) }
        if let v = self[key] as? String { return Int(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return nil
    }
    
    /// 读取`Int8`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func int8Value(_ key: String, default value: Int8 = 0) -> Int8 {
        return int8(key) ?? value
    }
    
    /// 读取`Int8?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func int8(_ key: String) -> Int8? {
        if let v = self[key] as? Int8 { return v }
        if let v = self[key] as? NSNumber { return v.int8Value }
        if let v = self[key] as? Double { return Int8(exactly: v) ?? Int8(clamping: Int(v)) }
        if let v = self[key] as? String { return Int8(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return nil
    }
    
    /// 读取`UInt8`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func uint8Value(_ key: String, default value: UInt8 = 0) -> UInt8 {
        return uint8(key) ?? value
    }
    
    /// 读取`UInt8?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func uint8(_ key: String) -> UInt8? {
        if let v = self[key] as? UInt8 { return v }
        if let v = self[key] as? NSNumber { return v.uint8Value }
        if let v = self[key] as? Double { return UInt8(exactly: v) ?? UInt8(clamping: Int(v)) }
        if let v = self[key] as? String { return UInt8(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return nil
    }
    
    /// 读取`Int64`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func int64Value(_ key: String, default value: Int64 = 0) -> Int64 {
        return int64(key) ?? value
    }
    
    /// 读取`Int64?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func int64(_ key: String) -> Int64? {
        if let v = self[key] as? Int64 { return v }
        if let v = self[key] as? NSNumber { return v.int64Value }
        if let v = self[key] as? Double { return Int64(v) }
        if let v = self[key] as? String { return Int64(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return nil
    }
    
    /// 读取`UInt64`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func uint64Value(_ key: String, default value: UInt64 = 0) -> UInt64 {
        return uint64(key) ?? value
    }
    
    /// 读取`UInt64?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func uint64(_ key: String) -> UInt64? {
        if let v = self[key] as? UInt64 { return v }
        if let v = self[key] as? NSNumber { return v.uint64Value }
        if let v = self[key] as? Double { return UInt64(v) }
        if let v = self[key] as? String { return UInt64(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return nil
    }
    
    /// 读取`Double`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func doubleValue(_ key: String, default value: Double = 0) -> Double {
        return double(key) ?? value
    }
    
    /// 读取`Double?`值
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func double(_ key: String) -> Double? {
        if let v = self[key] as? Double { return v }
        if let v = self[key] as? NSNumber { return v.doubleValue }
        if let v = self[key] as? Int { return Double(v) }
        if let v = self[key] as? String { return Double(v) }
        return nil
    }
    
    /// 读取`[String: Any]`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func dictValue(_ key: String, default value: [String: Any] = [:]) -> [String: Any] {
        return dict(key) ?? value
    }
    
    /// 读取`[String: Any]?`值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func dict(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
    
    /// 读取`[T]`值，不存在时返回[]
    /// - Parameters:
    ///   - key: key值
    ///   - type: 数组内的类型，必须是可通过 as? 从 JSON 数组中转换的类型
    /// - Returns: 返回值
    func arrayValue<T>(_ key: String, of type: T.Type) -> [T] {
        return self[key] as? [T] ?? []
    }
    
    /// 读取`[T]?`值
    /// - Parameters:
    ///   - key: key值
    ///   - type: 数组内的类型，必须是可通过 as? 从 JSON 数组中转换的类型
    /// - Returns: 返回值
    func array<T>(_ key: String, of type: T.Type) -> [T]? {
        return self[key] as? [T]
    }
    
    /// 读取`Date`值
    /// - Parameters:
    ///    - key: key值
    ///    - value: 解析失败返回的值
    /// - Returns: 返回值
    func dateValue(_ key: String, default value: Date = Date()) -> Date {
        return date(key) ?? value
    }
    
    /// 读取`Date?`值
    /// - Parameter key: key值
    /// - Returns: 返回值
    func date(_ key: String) -> Date? {
        return self[key] as? Date
    }
    
    /// 读取`Data`值
    /// - Parameters:
    ///    - key: key值
    ///    - value: 解析失败返回的值
    /// - Returns: 返回值
    func dataValue(_ key: String, default value: Data = Data()) -> Data {
        return data(key) ?? value
    }
    
    /// 读取`Data?`值
    /// - Parameter key: key值
    /// - Returns: 返回值
    func data(_ key: String) -> Data? {
        return self[key] as? Data
    }
    
}


public extension Dictionary where Key == String {
    
    /// 读取`Array`并 1: 1转换成模型数组
    /// - Parameters:
    ///   - key: key值
    ///   - type: 需要转换的模型
    /// - Returns: 返回值
    func models<T: JsonInitializable>(_ key: String, of type: T.Type) -> [T] {
        let arr = self.arrayValue(key, of: [String: Any].self)
        return arr.models(of: T.self)
    }
    
    /// 读取`Array`并转换成模型数组，会过滤掉无效的数据
    /// - Parameters:
    ///   - key: key值
    ///   - type: 需要转换的模型
    /// - Returns: 返回值
    func strictModels<T: JsonInitializableNullable>(_ key: String, of type: T.Type) -> [T] {
        let arr = self.arrayValue(key, of: [String: Any].self)
        return arr.strictModels(of: T.self)
    }
    
}

public extension Dictionary where Key == String {
    
    /// 过滤values中的空值
    /// - Returns: 返回去掉空值的`[Key:Value]`
    func filterNilValues() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, rawValue) in self {
            
            // 解包，过滤nil
            guard let unwrapped = unwrap(rawValue) else { continue }
            
            // 过滤掉 NSNull
            if rawValue is NSNull { continue }
            
            // 递归处理子字典
            if let subDict = unwrapped as? [String: Any] {
                result[key] = subDict.filterNilValues
                continue
            }
            
            // 递归处理数组
            if let subArray = unwrapped as? [Any] {
                result[key] = cleanArrayNilValues(subArray)
                continue
            }
            
            result[key] = unwrapped
        }
        return result
    }
    
    /// 转换成json 字符串
    /// - Parameter pretty: 是否美化显示格式
    /// - Parameter sorted: 对key进行排序
    /// - Returns: json字符串
    func toJsonString(pretty: Bool = false, sorted: Bool = false) throws -> String {
        
        let jsonCompatibleDict = toJsonObject()
        guard JSONSerialization.isValidJSONObject(jsonCompatibleDict) else {
            throw NSError(domain: "Json Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dictionary contains non-JSON objects"])
        }
        
        var options: JSONSerialization.WritingOptions = []
        if pretty { options.insert(.prettyPrinted) }
        if sorted { options.insert(.sortedKeys) }
        
        let data = try JSONSerialization.data(withJSONObject: jsonCompatibleDict, options: options)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    /// 转换成不含nil的对象
    fileprivate func toJsonObject() -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, rawValue) in self {
            if let unwrapped = unwrap(rawValue) {
                if let subDict = unwrapped as? [String: Any] {
                    result[key] = subDict.toJsonObject()
                } else if let subArray = unwrapped as? [Any] {
                    result[key] = subArray.map { item -> Any in
                        if let dictItem = item as? [String: Any] {
                            return dictItem.toJsonObject()
                        }
                        return unwrap(item) ?? NSNull()
                    }
                } else {
                    result[key] = unwrapped
                }
            } else {
                result[key] = NSNull()
            }
        }
        
        return result
    }
    
    // 过滤掉数组中的空值
    fileprivate func cleanArrayNilValues(_ array: [Any]) -> [Any] {
        return array.compactMap { item -> Any? in
            guard let unwrapped = unwrap(item),
                  !(unwrapped is NSNull) else {
                return nil
            }
            
            // 如果元素是字典，递归调用 filterNilValues
            if let dictItem = unwrapped as? [String: Any] {
                return dictItem.filterNilValues
            }
            
            // 如果元素是子数组（多维数组），递归调用本函数
            if let arrayItem = unwrapped as? [Any] {
                return cleanArrayNilValues(arrayItem)
            }
            return unwrapped
        }
    }
    
    // 拆解Any包装下的Optional
    fileprivate func unwrap(_ any: Any) -> Any? {
        let mirror = Mirror(reflecting: any)
        // 如果不是 Optional 类型，直接返回原值
        guard mirror.displayStyle == .optional else { return any }
        // 如果是 Optional，检查是否有子节点，Optional.some才会包含1个子节点
        guard let firstChild = mirror.children.first else { return nil }
        // 递归解包，防止多重Optional
        return unwrap(firstChild.value)
    }

}

public extension Dictionary {
    
    static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result.merge(rhs, uniquingKeysWith: { _, new in new })
        return result
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(rhs, uniquingKeysWith: { _, new in new })
    }
}


public extension String {
    
    /// 将json字符串转换成 [String: Any]
    /// - Returns: 返回转换后的dict
    func toJsonDict() throws -> [String: Any] {
        guard let data = self.data(using: .utf8) else {
            throw NSError(domain: "Json Error", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 string"])
        }
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "Json Error", code: -3, userInfo: [NSLocalizedDescriptionKey: "JSON is not a dictionary"])
        }
        return json
    }
    
}

public extension Array where Element == [String: Any] {
    
    /// 1: 1转换成模型数组
    /// - Parameters:
    ///   - key: key值
    ///   - T: 需要转换的模型
    /// - Returns: 返回值
    func models<T: JsonInitializable>(of type: T.Type) -> [T] {
        return map { T(json: $0) }
    }
    
    /// 转换成模型数组，会过滤掉无效的数据
    /// - Parameters:
    ///   - T: 需要转换的模型
    /// - Returns: 返回值
    func strictModels<T: JsonInitializableNullable>(of type: T.Type) -> [T] {
        return compactMap { T(strictJson: $0) }
    }
}

/// 字典转模型的协议， 肯定会成功
public protocol JsonInitializable {
    init(json: [String: Any])
}

/// 字典转模型的协议, 允许失败
public protocol JsonInitializableNullable {
    init?(strictJson: [String: Any])
}

public extension BinaryInteger {
    
    /// 转成文件大小
    func fileSizeString(units: ByteCountFormatter.Units = [.useAll]) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = units
        return formatter.string(fromByteCount: Int64(clamping: self))
    }
    
    /// 转成MEM大小
    func memorySizeString(units: ByteCountFormatter.Units = [.useAll]) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = units
        return formatter.string(fromByteCount: Int64(clamping: self))
    }
    
    /// 转成磁盘大小
    /// - Parameters:
    ///   - units: 显示的单位
    ///   - hideSpace: 是否隐藏中间的空格  `1 MB` or `1MB`
    ///   - appendingUint: 在后面拼接 `/s`或其他
    /// - Returns: 返回格式化后的字符串
    func diskSizeString(units: ByteCountFormatter.Units = [.useAll], hideSpace: Bool = true, appendingUint: String? = nil) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        formatter.allowedUnits = units
        formatter.isAdaptive = true // 自适应单位
        formatter.zeroPadsFractionDigits = false // 控制小数部分末尾要不要补0
        var value = formatter.string(fromByteCount: Int64(clamping: self))
        if hideSpace {
            value = value.replacingOccurrences(of: " ", with: "")
        }
        return value + (appendingUint ?? "")
    }
    
    /// 转成网速大小
    /// - Parameters:
    ///   - units: 显示的单位
    ///   - hideSpace: 是否隐藏中间的空格  `1 MB/s` or `1MB/s`
    ///   - appendingUint: 在后面拼接 `/s`或其他
    /// - Returns: 返回格式化后的字符串
    func networkSpeedString(units: ByteCountFormatter.Units = [.useAll], hideSpace: Bool = true, appendingUint: String? = "/s") -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = units
        formatter.isAdaptive = true
        formatter.zeroPadsFractionDigits = false
        var value = formatter.string(fromByteCount: Int64(clamping: self))
        if hideSpace {
            value = value.replacingOccurrences(of: " ", with: "")
        }
        return value + (appendingUint ?? "")
    }
}
