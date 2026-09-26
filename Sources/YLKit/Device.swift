//
//  Device.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/12/31.
//

import Foundation
import IOKit

struct Device {
    
    struct Core {
        
        /// CPU 物理核心总数
        ///
        /// 样例：
        /// 12
        ///
        /// 对应 system_profiler：
        /// Total Number of Cores: 12 (8 Performance and 4 Efficiency)
        let total: Int
        
        /// 性能核心数量（Performance Cores）
        ///
        /// 样例：
        /// 8
        ///
        /// 对应 system_profiler：
        /// 8 Performance
        ///
        /// Intel Mac 通常为 0
        let performance: Int
        
        /// 能效核心数量（Efficiency Cores）
        ///
        /// 样例：
        /// 4
        ///
        /// 对应 system_profiler：
        /// 4 Efficiency
        ///
        /// Intel Mac 通常为 0
        let efficiency: Int
    }
    
    // MARK: - Hardware Overview
    
    /// Mac 产品名称
    ///
    /// 样例：
    /// MacBook Pro
    /// MacBook Air
    /// MacBookPro16,1
    /// MacBook Pro (16-inch, 2021)
    /// iMac19,1
    ///
    /// 对应 system_profiler：
    /// Model Name: MacBook Pro
    static let modelName: String = getModelName() ?? ""
    
    /// Mac 型号标识符
    ///
    /// 样例：
    /// Mac14,10
    /// Mac16,5
    /// MacBookPro18,3
    ///
    /// 对应 system_profiler：
    /// Model Identifier: Mac14,10
    ///
    /// 来源：
    /// sysctlbyname("hw.model")
    static let modelIdentifier: String = getModelIdentifier() ?? ""
    
    /// Mac 销售型号 / 订货号
    ///
    /// 样例：
    /// MNW83CH/A
    /// MX2H3CH/A
    ///
    /// 对应 system_profiler：
    /// Model Number: MNW83CH/A
    ///
    /// 注意：
    /// 这个字段并不是所有机型、所有系统版本都一定能从 IORegistry 稳定取得。
    static let modelNumber: String = getModelNumber() ?? ""
    
    /// 芯片名称 / CPU 名称
    ///
    /// Apple Silicon 样例：
    /// Apple M1
    /// Apple M1 Pro
    /// Apple M2 Pro
    /// Apple M3 Max
    /// Apple M4
    ///
    /// Intel 样例：
    /// Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
    ///
    /// 对应 system_profiler：
    /// Chip: Apple M2 Pro
    ///
    /// Intel 机器对应：
    /// Processor Name / Processor Speed
    static let chip: String = getChip() ?? ""
    
    /// 物理内存总容量，单位：Byte
    ///
    /// 样例：
    /// 17179869184
    ///
    /// 即：
    /// 16 GB
    ///
    /// 对应 system_profiler：
    /// Memory: 16 GB
    ///
    /// 使用时可以自行格式化：
    ///
    /// ByteCountFormatter.string(
    ///     fromByteCount: Int64(Device.memory),
    ///     countStyle: .memory
    /// )
    static let memory: UInt64 = ProcessInfo.processInfo.physicalMemory
    
    /// CPU 核心信息
    ///
    /// 样例：
    ///
    /// Apple M2 Pro：
    /// Core(
    ///     total: 12,
    ///     performance: 8,
    ///     efficiency: 4
    /// )
    ///
    /// 对应 system_profiler：
    /// Total Number of Cores: 12 (8 Performance and 4 Efficiency)
    static let core: Core = getCore()
    
    /// 设备序列号
    ///
    /// 样例：
    /// V7TXXNHYX5
    ///
    /// 对应 system_profiler：
    /// Serial Number (system): V7TXXNHYX5
    ///
    /// 来源：
    /// IOPlatformSerialNumber
    static let serialNumber: String = getSerialNumber() ?? ""
    
    /// 硬件 UUID
    ///
    /// 样例：
    /// 8E1FDBCB-59B4-5A39-B61E-E133C5823DB9
    ///
    /// 对应 system_profiler：
    /// Hardware UUID: 8E1FDBCB-59B4-5A39-B61E-E133C5823DB9
    ///
    /// 来源：
    /// IOPlatformUUID
    static let uuid: String = getHardwareUUID() ?? ""
    
    // MARK: - Model Name
    
    /// 获取 Mac 产品名称
    ///
    /// 目标值样例：
    /// MacBook Pro
    ///
    /// 对应：
    /// Model Name: MacBook Pro
    private static func getModelName() -> String? {
        guard let value = ioRegistryProperty(serviceName: "IOPlatformExpertDevice", key: "product-name") else {
            return nil
        }
        
        return string(from: value)
    }
    
    // MARK: - Model Identifier
    
    /// 获取型号标识符
    ///
    /// 目标值样例：
    /// Mac14,10
    ///
    /// 对应：
    /// Model Identifier: Mac14,10
    private static func getModelIdentifier() -> String? { sysctlString("hw.model") }
    
    // MARK: - Model Number
    
    /// 获取销售型号 / 订货号
    ///
    /// 目标值样例：
    /// MNW83CH/A
    ///
    /// 对应：
    /// Model Number: MNW83CH/A
    private static func getModelNumber() -> String? {
        let entry = IORegistryEntryFromPath(ioKitPort, "IODeviceTree:/")
        guard entry != 0 else { return nil }
        defer { IOObjectRelease(entry) }
        
        let keys = [
            "model-number",
            "part-number"
        ]
        
        for key in keys {
            guard let value = IORegistryEntryCreateCFProperty(entry, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() else {
                continue
            }
            
            if let result = string(from: value),
               !result.isEmpty {
                return result
            }
        }
        
        return nil
    }
    
    // MARK: - Chip
    
    /// 获取芯片名称
    ///
    /// Apple Silicon 目标值样例：
    /// Apple M2 Pro
    ///
    /// Intel 目标值样例：
    /// Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
    ///
    /// 对应：
    /// Chip: Apple M2 Pro
    private static func getChip() -> String? { sysctlString("machdep.cpu.brand_string") }
    
    // MARK: - Core
    
    /// 获取 CPU 核心信息
    ///
    /// 样例：
    ///
    /// Apple M2 Pro：
    /// total       = 12
    /// performance = 8
    /// efficiency  = 4
    ///
    /// 对应：
    /// Total Number of Cores: 12 (8 Performance and 4 Efficiency)
    private static func getCore() -> Core {
        
        /// 物理核心总数
        ///
        /// 样例：
        /// 12
        let total = sysctlInt("hw.physicalcpu") ?? ProcessInfo.processInfo.processorCount
        
#if arch(arm64)
        
        /// 性能核心数量
        ///
        /// Apple Silicon 样例：
        /// 8
        let performance = sysctlInt("hw.perflevel0.physicalcpu") ?? 0
        
        /// 能效核心数量
        ///
        /// Apple Silicon 样例：
        /// 4
        let efficiency = sysctlInt("hw.perflevel1.physicalcpu") ?? 0
        
#else
        
        /// Intel Mac没有 p/e Core 分类
        let performance = 0
        let efficiency = 0
        
#endif
        
        return Core(total: total, performance: performance, efficiency: efficiency)
    }
    
    // MARK: - Serial Number
    
    /// 获取设备序列号
    ///
    /// 目标值样例：
    /// V7TXXNHYX5
    ///
    /// 对应：
    /// Serial Number (system): V7TXXNHYX5
    private static func getSerialNumber() -> String? {
        guard let value = ioRegistryProperty(serviceName: "IOPlatformExpertDevice", key: kIOPlatformSerialNumberKey) else {
            return nil
        }
        
        return string(from: value)
    }
    
    // MARK: - Hardware UUID
    
    /// 获取硬件 UUID
    ///
    /// 目标值样例：
    /// 8E1FDBCB-59B4-5A39-B61E-E133C5823DB9
    ///
    /// 对应：
    /// Hardware UUID: 8E1FDBCB-59B4-5A39-B61E-E133C5823DB9
    private static func getHardwareUUID() -> String? {
        guard let value = ioRegistryProperty(serviceName: "IOPlatformExpertDevice", key: kIOPlatformUUIDKey) else {
            return nil
        }
        
        return string(from: value)
    }
    
    // MARK: - Sysctl
    
    /// 获取 sysctl 字符串类型数据
    ///
    /// 使用样例：
    ///
    /// sysctlString("hw.model")
    /// -> Mac14,10
    ///
    /// sysctlString("hw.machine")
    /// -> arm64
    ///
    /// Intel：
    /// sysctlString("machdep.cpu.brand_string")
    /// -> Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
    private static func sysctlString(_ name: String) -> String? {
        // 先获取大小
        var size: size_t = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0,
              size > 0 else {
            return nil
        }
        // 再获取内容
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else {
            return nil
        }
        
        return String(cString: buffer)
    }
    
    /// 获取 sysctl Int32 类型数据
    ///
    /// 使用样例：
    ///
    /// sysctlInt("hw.physicalcpu")
    /// -> 12
    ///
    /// sysctlInt("hw.perflevel0.physicalcpu")
    /// -> 8
    ///
    /// sysctlInt("hw.perflevel1.physicalcpu")
    /// -> 4
    private static func sysctlInt(_ name: String) -> Int? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else {
            return nil
        }
        
        return Int(value)
    }
    
    // MARK: - IOKit
    
    /// 从 IORegistry 指定 Service 中获取属性
    ///
    /// 使用样例：
    ///
    /// serviceName:
    /// IOPlatformExpertDevice
    ///
    /// key:
    /// IOPlatformSerialNumber
    ///
    /// 可能返回：
    /// V7TXXNHYX5
    private static func ioRegistryProperty(serviceName: String, key: String) -> CFTypeRef? {
        
        guard let matching = IOServiceMatching(serviceName) else { return nil }
        
        let service = IOServiceGetMatchingService(ioKitPort, matching)
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        
        return IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
    }
    
    // MARK: - Convert
    
    /// 将 IORegistry 返回值转换为 String
    ///
    /// IORegistry 中常见返回类型：
    ///
    /// String
    /// Data
    ///
    /// Data 样例：
    /// "MacBook Pro\0"
    ///
    /// 转换后：
    /// "MacBook Pro"
    private static func string(from value: Any) -> String? {
        
        if let string = value as? String {
            return string.trimmingCharacters(in: .controlCharacters).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let data = value as? Data {
            guard let string = String(data: data, encoding: .utf8) else { return nil }
            return string.trimmingCharacters(in: .controlCharacters).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    /// 当前系统使用的 IOKit 默认通信端口
    ///
    /// macOS 12.0+：
    /// kIOMainPortDefault
    ///
    /// macOS 10.14 ~ 11：
    /// kIOMasterPortDefault
    static var ioKitPort: mach_port_t {
        if #available(macOS 12.0, *) {
            return kIOMainPortDefault
        } else {
            return kIOMasterPortDefault
        }
    }
}
