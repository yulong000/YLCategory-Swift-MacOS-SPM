//
//  YLPermissionManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation
import AppKit

@objc public enum YLPermissionAuthType: UInt8 {
    case none
    case accessibility      // 辅助功能权限
    case fullDisk           // 完全磁盘权限
    case screenCapture      // 录屏权限
}

public class YLPermissionManager: NSObject {
    
    public static let shared = YLPermissionManager()
    private override init() {}
    
    /// 是否所有权限都已授权
    public var allAuthPassed: Bool {
        var flag = true
        for model in authTypes {
            switch model.authType {
            case .accessibility:
                flag = flag && getPrivacyAccessibilityIsEnabled()
            case .screenCapture:
                flag = flag && getScreenCaptureIsEnabled()
            case .fullDisk:
                flag = flag && getFullDiskAccessIsEnabled()
            default:
                break
            }
            if flag == false { break }
        }
        return flag
    }
    /// 是否点击了跳过授权
    public var isSkipped: Bool { skipped }
    
    /// 点击了跳过授权
    public var skipHandler: (() -> Void)?
    /// 点击了退出
    public var quitHandler: (() -> Void)?
    /// 所有权限都已授权后的回调
    public var allAuthPassedHandler: (() -> Void)?
    
    /// 教学视频链接，不设置则不显示 观看权限设置教学>> 的按钮
    public var tutorialLink: String?
    
    // MARK: - 循环监听
    
    /// 一次性监听所有权限，如果有权限未授权，则会显示授权窗口，当所有权限都授权时，则自动隐藏
    /// - Parameters:
    ///   - authTypes: 需要授权的权限
    ///   - repeatSeconds: 定时监听的秒数，一旦某个权限有变化，就会更新显示
    private var second = 0 // 记录过了多少秒
    public func monitorPermissionAuth(_ authTypes: [YLPermissionModel], repeatSeconds: Int) {
        self.authTypes = authTypes
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            if repeatSeconds <= 0 {
                // 不需要循环检测
                if self.allAuthPassed {
                    self.monitorTimer?.invalidate()
                    self.monitorTimer = nil
                    if self.permissionWC != nil {
                        self.passAuth()
                    }
                    return
                }

                // 已有授权窗口，正常刷新
                if self.permissionWC != nil {
                    self.permissionWC?.permissionVc.refreshAllAuthState()
                    return
                }

                // 首次未通过，稍后复核，避免偶发误判
                self.recheckPermissionAuth(authTypes, timer: timer, stopMonitoring: true)
            } else {
                self.second += 1
                if self.second >= repeatSeconds {
                    // 达到了设置的间隔秒数
                    self.second = 0
                    if self.allAuthPassed == false {
                        // 首次未通过，稍后复核，避免后台检测时偶发误判
                        if self.permissionWC == nil {
                            self.recheckPermissionAuth(authTypes, timer: timer, stopMonitoring: false)
                        }
                    } else {
                        // 都已授权
                        if self.permissionWC != nil {
                            self.passAuth()
                        }
                    }
                } else if self.permissionWC != nil {
                    // 如果授权窗口在，每秒刷新一次状态
                    self.permissionWC?.permissionVc.refreshAllAuthState()
                }
            }
        })
    }
    
    
    // MARK: - 一次性监听
    
    // MARK: 检查多个权限是否同时开启
    public func checkPermissionAuth(_ authTypes: [YLPermissionAuthType]) -> Bool {
        var flag = true
        for type in authTypes {
            switch type {
            case .accessibility:
                flag = flag && getPrivacyAccessibilityIsEnabled()
            case .screenCapture:
                flag = flag && getScreenCaptureIsEnabled()
            case .fullDisk:
                flag = flag && getFullDiskAccessIsEnabled()
            default:
                break
            }
            if flag == false { break }
        }
        return flag
    }
    
    // MARK: 显示授权窗口
    public func showPermissionAuth(_ authTypes: [YLPermissionModel]) {
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            if self.permissionWC == nil {
                self.presentPermissionWindow(authTypes, stopMonitoring: true)
            } else {
                self.permissionWC?.permissionVc.refreshAllAuthState()
            }
        })
    }
    
    // MARK: 检查某个权限是否开启，如果未开启，则弹出Alert，请求打开权限
    @discardableResult
    public func checkPermission(authType type:YLPermissionAuthType) -> Bool {
        var flag = true
        var selector: Selector?
        var tips: String = ""
        switch type {
        case .accessibility:
            flag = getPrivacyAccessibilityIsEnabled()
            tips = "Accessibility Tips"
            selector = #selector(openPrivacyAccessibilitySetting)
        case .screenCapture:
            flag = getScreenCaptureIsEnabled()
            tips = "ScreenCapture Tips"
            selector = #selector(openScreenCaptureSetting)
        case .fullDisk:
            flag = getFullDiskAccessIsEnabled()
            tips = "Full disk access Tips"
            selector = #selector(openFullDiskAccessSetting)
        default:
            break
        }
        if flag == false {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLPermissionManager.localize("Kind tips")
            alert.informativeText = String(format: YLPermissionManager.localize(tips), YLPermissionManager.appName)
            alert.addButton(withTitle: YLPermissionManager.localize("To Authorize"))
            alert.addButton(withTitle: YLPermissionManager.localize("Cancel"))
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let sel = selector, responds(to: sel)  {
                    perform(sel)
                }
            }
        }
        return flag
    }
    
    // MARK: 获取辅助功能权限是否打开
    public func getPrivacyAccessibilityIsEnabled() -> Bool { AXIsProcessTrusted() }
    
    // MARK: 获取录屏权限是否打开
    public func getScreenCaptureIsEnabled() -> Bool {
        guard #available(macOS 10.15, *) else { return true }
        let currentPid = NSRunningApplication.current.processIdentifier
        // 获取当前屏幕上的窗口信息
        guard let windowList = CGWindowListCopyWindowInfo(.excludeDesktopElements, kCGNullWindowID) as? [[CFString: Any]] else { return false }
        for dict in windowList {
            // 能获取到名字
            guard dict[kCGWindowName] != nil  else { continue }
            // 排除当前app
            guard let pid = dict[kCGWindowOwnerPID] as? pid_t, pid != currentPid else { continue }
            // 排除dock
            if let runningApp = NSRunningApplication(processIdentifier: pid),
               let execName = runningApp.executableURL?.lastPathComponent,
               execName != "Dock" {
                return true
            }
        }
        return false
    }
    
    // MARK: 获取完全磁盘权限是否打开
    public func getFullDiskAccessIsEnabled() -> Bool {
        if #available(macOS 10.14, *) {
            let isSandbox = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
            let userHomePath: String
            
            if isSandbox {
                guard let pw = getpwuid(getuid()), let homeDir = pw.pointee.pw_dir else {
                    fatalError("Failed to retrieve home directory in sandbox mode.")
                }
                userHomePath = String(cString: homeDir)
            } else {
                userHomePath = NSHomeDirectory()
            }
            
            let testFiles = [
                "\(userHomePath)/Library/Safari/CloudTabs.db",
                "\(userHomePath)/Library/Safari/Bookmarks.plist",
                "/Library/Application Support/com.apple.TCC/TCC.db",
                "/Library/Preferences/com.apple.TimeMachine.plist"
            ]
            
            for file in testFiles {
                let fd = open(file, O_RDONLY)
                if fd != -1 {
                    close(fd)
                    return true
                }
            }
            return false
        }
        return true
    }
    
    // MARK: 打开辅助功能权限设置窗口
    @objc public func openPrivacyAccessibilitySetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        NSWorkspace.shared.open(URL(string: url)!)
        // 模拟键盘事件，将app带入到权限列表
        guard let eventRef = CGEvent(source: nil) else { return }
        let point = eventRef.location
        guard let mouseEventRef = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else { return }
        mouseEventRef.post(tap: .cghidEventTap)
    }
    
    // MARK: 打开录屏权限设置窗口
    @objc public func openScreenCaptureSetting() {
        // 创建一个 1x1 的屏幕截图，检查屏幕录制权限
        let _ = CGWindowListCreateImage(CGRect(x: 0, y: 0, width: 1, height: 1), .optionOnScreenOnly, kCGNullWindowID, [])
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: 打开完全磁盘权限设置窗口
    @objc public func openFullDiskAccessSetting() {
        let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    // MARK: - private
    
    private var permissionWC: YLPermissionWindowController?
    private var authTypes: [YLPermissionModel] = []
    private var monitorTimer: Timer? = nil
    private var skipped: Bool = false
    
    /// 首次检测失败后延迟复核，连续两次失败才显示授权窗口
    private func recheckPermissionAuth(_ authTypes: [YLPermissionModel], timer: Timer, stopMonitoring: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self,
                  let currentTimer = self.monitorTimer,
                  currentTimer === timer,
                  currentTimer.isValid else { return }
            if self.allAuthPassed {
                if stopMonitoring {
                    currentTimer.invalidate()
                    self.monitorTimer = nil
                }
                if self.permissionWC != nil {
                    self.passAuth()
                }
                return
            }
            // 再次未通过，才弹出授权窗口
            self.presentPermissionWindow(authTypes, stopMonitoring: stopMonitoring)
        }
    }

    /// 创建授权窗口；持续监听时，授权通过后仍保留定时器
    private func presentPermissionWindow(_ authTypes: [YLPermissionModel], stopMonitoring: Bool) {
        guard permissionWC == nil else { return }
        permissionWC = YLPermissionWindowController()
        permissionWC?.permissionVc.allAuthPassedHandler = { [weak self] in
            // 已全部授权
            guard let self = self else { return }
            if stopMonitoring {
                self.monitorTimer?.invalidate()
                self.monitorTimer = nil
            }
            self.passAuth()
        }
        permissionWC?.permissionVc.skipHandler = { [weak self] in
            // 跳过
            self?.skipAuth()
        }
        permissionWC?.permissionVc.quitHandler = { [weak self] in
            // 退出
            self?.quitHandler?()
        }
        if stopMonitoring {
            permissionWC?.closeHandler = { [weak self] in
                // 点击了关闭按钮
                self?.monitorTimer?.invalidate()
                self?.monitorTimer = nil
                self?.permissionWC = nil
            }
        }
        permissionWC?.permissionVc.authTypes = authTypes
        permissionWC?.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: 通过授权
    private func passAuth() {
        permissionWC?.close()
        permissionWC = nil
        allAuthPassedHandler?()
    }
    // MARK: 跳过授权
    private func skipAuth() {
        permissionWC?.close()
        permissionWC = nil
        monitorTimer?.invalidate()
        monitorTimer = nil
        skipped = true
        skipHandler?()
    }
    
    // MARK: - 本地化相关
    
    static func localize(_ key: String) -> String { NSLocalizedString(key, bundle: .module, comment: "") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
                                 Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
                                 Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    
    private static func bundleImage(_ name: String) -> NSImage {
        if let imageUrl = Bundle.module.url(forResource: name, withExtension: ""),
           let image = NSImage(contentsOf: imageUrl) {
            return image
        }
        return NSImage()
    }
}

