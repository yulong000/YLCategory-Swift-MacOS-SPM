//
//  YLUpdateManager.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import AppKit

public class YLUpdateManager: NSObject {
    
    public static let shared = YLUpdateManager()
    private override init() {}
    
    /// 设置app store更新参数
    /// - Parameters:
    ///   - appID: app 的唯一标识
    ///   - xml: 强制更新配置链接（下载XML配置文件，根据配置参数判断）
    ///   - localDate: yyyy-MM-dd,  本地的过期时间，如果XML获取不到，且超过这个时间，就强制更新
    ///   - skipEnable: 是否可以跳过当前更新版本
    ///   当有新版本时，从该链接获取配置信息，来判断是否强制更新
    ///         "Name" :  "xxx"                                      app名字,
    ///         "BundleId": "com.xxxx.xxxx"                  app的bundle Id,
    ///         "ForceUpdateToTheLatest":  false        是否强制更新到最新版本
    ///         "MiniVersion":  "1.0.0"                           可以使用的最小版本号，小于该版本号，需要强制升级
    ///         "ExpiredDate":  "2025-10-30"                过期时间
    ///         "ExpiredOSVersion":  "17.0"                  过期的系统版本号
    ///         4个判断条件，优先级从上往下递减
    public func set(appID: String, forceUpdate xml: String? = nil, expiredDate localDate: String? = nil, isSkipEnable: Bool = false) {
        self.appID = appID
        self.forceUpdateUrl = xml
        self.isSkipEnable = isSkipEnable
        self.localExpiredDate = localDate.flatMap { dateWith($0) }
        if xml == nil || xml!.isEmpty {
            self.checkLocalExpiredDate()
        }
    }
    
    /// 设置线下版的强制更新参数
    /// - Parameters:
    ///   - xml: 强制更新XML下载地址
    ///   - localDate: yyyy-MM-dd,  本地的过期时间，如果XML获取不到，且超过这个时间，就强制更新
    ///   - url: 线下版的下载地址
    public func setOffline(forceUpdate xml: String? = nil, expiredDate localDate: String? = nil, downloadUrl url: String) {
        self.forceUpdateUrl = xml
        self.offlineDownloadUrl = url
        self.localExpiredDate = localDate.flatMap { dateWith($0) }
        if xml == nil || xml!.isEmpty {
            self.checkLocalExpiredDate()
        }
        
        guard let xml,
              !xml.isEmpty,
              let xmlURL = URL(string: xml) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: xmlURL) { [self] data, response, error in
            guard let data = data, error == nil else {
                // 接口报错，判断本地时间
                checkLocalExpiredDate()
                return
            }
            
            guard let update = try? YLUpdateXMLModel.parse(data: data),
                  update.BundleId == Bundle.main.bundleIdentifier else {
#if DEBUG
            print("❌ 线下版 xml 强制更新内容 解析失败:\n\(String(data: data, encoding: .utf8) ?? "")")
#endif
                return
            }
#if DEBUG
            print("✅ 线下版 xml 强制更新内容 信息:\n\(update.toJsonString())")
#endif
            // 解析成功
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let mini = update.MiniVersion, !mini.isEmpty,
               mini.compare(appVersion, options: .numeric) == .orderedDescending {
                // 低于设置的最小版本号
                showForceUpdateAlert(downloadUrl: url)
                return
            }
            if let expiredDate = update.ExpiredDate, !expiredDate.isEmpty {
                // 设置了过期时间
                if let d = dateWith(expiredDate), d.timeIntervalSinceNow <= 0 {
                    showDateExpiredAlert(downloadUrl: url)
                    return
                }
            }
            if let expiredOSVersion = update.ExpiredOSVersion, !expiredOSVersion.isEmpty {
                // 设置了过期系统版本
                let sv = ProcessInfo.processInfo.operatingSystemVersion
                let sysVersion: String = String(format: "%ld.%ld.%ld", sv.majorVersion, sv.minorVersion, sv.patchVersion)
                if sysVersion.compare(expiredOSVersion, options: .numeric) != .orderedAscending {
                    showOSVersionExpiredAlert(downloadUrl: url)
                    return
                }
            }
        }
        task.resume()
    }
    
    // MARK: 检查设置的本地过期时间
    private func checkLocalExpiredDate() {
        guard let localExpiredDate,
              localExpiredDate.timeIntervalSinceNow <= 0,
              let downloadUrl = appStoreUrl ?? offlineDownloadUrl else {
            return
        }
        showDateExpiredAlert(downloadUrl: downloadUrl)
    }
    
    // MARK: - Private
    
    /// app ID
    private var appID: String? {
        didSet {
            guard let appID = appID, !appID.isEmpty else { return }
            let countryCode = Locale.current.regionCode?.lowercased() ?? ""
            appStoreUrl = "itms-apps://itunes.apple.com/cn/app/id" + appID
            appUpdateUrl = "http://itunes.apple.com/lookup?id=\(appID)&country=\(countryCode)&entity=desktopSoftware"
            appIntroduceUrl = "https://apps.apple.com/cn/app/id" + appID
        }
    }
    /// 是否可以跳过当前更新版本
    private var isSkipEnable: Bool = false
    /// 强制更新xml文件地址
    private(set) var forceUpdateUrl: String?
    /// 线下版的下载地址
    private(set) var offlineDownloadUrl: String?
    /// 本地过期时间，防止有人禁用了网络，屏蔽更新
    private var localExpiredDate: Date? = nil
    
    /// app应用商店地址
    private(set) var appStoreUrl: String?
    /// app更新地址
    private(set) var appUpdateUrl: String?
    /// app介绍
    private(set) var appIntroduceUrl: String?
    
    // MARK: - 国际化
    
    static func localize(_ key: String) -> String { NSLocalizedString(key, bundle: .module, comment: "") }
    static let appName: String = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
    Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
    Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
}


// MARK: - app store 版本
extension YLUpdateManager {
    
    // MARK: 检测app store的更新
    public func checkAppStoreUpdates(background: Bool = true) {
        guard let appUpdateUrl else { return }
        let task = URLSession.shared.dataTask(with: URL(string: appUpdateUrl)!) { data, response, error in
            guard let data = data, error == nil else {
                self.checkLocalExpiredDate()
                return
            }
            do {
                guard let resp = try JSONSerialization.jsonObject(with: data) as? [String : Any] else { return }
                if let resultCount = resp["resultCount"] as? Int, resultCount > 0,
                   let results = resp["results"] as? [[String : Any]],
                   let dict = results.first,
                   let latestVersion = dict["version"] as? String,
                   let info = dict["releaseNotes"] as? String,
                   let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   latestVersion.compare(appVersion, options: .numeric) == .orderedDescending {
#if DEBUG
                    print("当前版本：\(appVersion)  app store 最新版本: \(latestVersion)")
#endif
                    // 有新版本
                    if let forceUpdateUrl = self.forceUpdateUrl,
                       !forceUpdateUrl.isEmpty,
                       let forceUpdateURL = URL(string: forceUpdateUrl) {
                        // 有强制更新url
                        self.requestServerForUpdateWay(forceUpdateURL,
                                                       currentVersion: appVersion,
                                                       appStoreVersion: latestVersion,
                                                       updateInfo: info,
                                                       background: background
                        )
                    } else {
                        self.showNew(version: latestVersion, info: info, background: background)
                    }
                } else {
                    // 已经是最新版本
#if DEBUG
                    print("已经是最新版本")
#endif
                    if !background {
                        self.showCurrentVersionIsLatestAlert()
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: 请求服务器，判断如何升级
    private func requestServerForUpdateWay(_ url: URL, currentVersion: String, appStoreVersion: String, updateInfo: String, background: Bool) {
        
        guard let downloadUrl = appStoreUrl else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { [self] in
                guard let data, error == nil else {
                    checkLocalExpiredDate()
                    return
                }
                
                // 解析完成
                if let update = try? YLUpdateXMLModel.parse(data: data),
                   update.BundleId == Bundle.main.bundleIdentifier {
#if DEBUG
                    print("✅ App store 版 xml 强制更新内容 信息:\n\(update.toJsonString())")
#endif
                    // 解析成功
                    if let force = update.ForceUpdateToTheLatest, force {
                        // 强制升级到最新版
                        showForceUpdateAlert(downloadUrl: downloadUrl)
                        return
                    }
                    if let mini = update.MiniVersion, !mini.isEmpty,
                       mini.compare(currentVersion, options: .numeric) == .orderedDescending {
                        // 低于设置的最小版本号
                        showForceUpdateAlert(downloadUrl: downloadUrl)
                        return
                    }
                    if let expiredDate = update.ExpiredDate, !expiredDate.isEmpty {
                        // 设置了过期时间
                        if let d = dateWith(expiredDate), d.timeIntervalSinceNow <= 0 {
                            showDateExpiredAlert(downloadUrl: downloadUrl)
                            return
                        }
                    }
                    if let expiredOSVersion = update.ExpiredOSVersion, !expiredOSVersion.isEmpty {
                        // 设置了过期系统版本
                        let sv = ProcessInfo.processInfo.operatingSystemVersion
                        let sysVersion: String = String(format: "%ld.%ld.%ld", sv.majorVersion, sv.minorVersion, sv.patchVersion)
                        if sysVersion.compare(expiredOSVersion, options: .numeric) != .orderedAscending {
                            showOSVersionExpiredAlert(downloadUrl: downloadUrl)
                            return
                        }
                    }
                } else {
#if DEBUG
                    print("❌ App store 版 xml 强制更新内容 解析失败:\n\(String(data: data, encoding: .utf8) ?? "")")
#endif
                }
                // 普通升级
                showNew(version: appStoreVersion, info: updateInfo, background: background)
            }
        }.resume()
    }
    
    // MARK: 显示有新版本提示
    private func showNew(version: String, info: String, background: Bool) {
        if background,
           let skipVersion = UserDefaults.standard.string(forKey: "YLUpdateSkipVersion"),
           skipVersion == version {
            // 跳过
#if DEBUG
            print("设置了跳过该更新版本： \(version)")
#endif
            return
        }
        DispatchQueue.main.async { [self] in
            let wc = YLUpdateWindowController()
            wc.showNew(version: version, info: info, isSkipEnable: isSkipEnable && background)
            wc.window?.center()
            wc.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: 显示当前是最新版本
    private func showCurrentVersionIsLatestAlert() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLUpdateManager.localize("Kind tips")
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                alert.informativeText = appVersion + " " + YLUpdateManager.localize("Latest version")
            } else {
                alert.informativeText = YLUpdateManager.localize("Latest version")
            }
            alert.addButton(withTitle: YLUpdateManager.localize("Sure"))
            alert.runModal()
        }
    }
    
    // MARK: 显示强制升级
    public func showForceUpdateAlert(downloadUrl: String) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLUpdateManager.localize("Kind tips")
            alert.informativeText = YLUpdateManager.localize("Force Update Tips")
            alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
            alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
            let result = alert.runModal()
            if result == .alertFirstButtonReturn {
                if let url = URL(string: downloadUrl) {
                    NSWorkspace.shared.open(url)
                }
            }
            NSApp.terminate(nil)
        }
    }
    
    // MARK: 显示日期过期的alert弹窗
    public func showDateExpiredAlert(downloadUrl: String) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLUpdateManager.localize("Kind tips")
            alert.informativeText = String(format: YLUpdateManager.localize("Expire Tips"), YLUpdateManager.appName)
            alert.addButton(withTitle: YLUpdateManager.localize("Click to download"))
            alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: downloadUrl) {
                    NSWorkspace.shared.open(url)
                }
            }
            NSApp.terminate(nil)
        }
    }
    
    // MARK: 显示系统版本过期的alert弹窗
    public func showOSVersionExpiredAlert(downloadUrl: String) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = YLUpdateManager.localize("Kind tips")
            alert.informativeText = String(format: YLUpdateManager.localize("OS Expire Tips"), YLUpdateManager.appName)
            alert.addButton(withTitle: YLUpdateManager.localize("Click to update"))
            alert.addButton(withTitle: YLUpdateManager.localize("Quit"))
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: downloadUrl) {
                    NSWorkspace.shared.open(url)
                }
            }
            NSApp.terminate(nil)
        }
    }
    
    // MARK: 字符串转日期
    public func dateWith(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return formatter.date(from: dateStr)
    }
}

fileprivate struct YLUpdateXMLModel {
    /// app名字
    public var Name: String?
    /// app的bundle ID
    public var BundleId: String?
    /// 支持最小版本号，小于该版本号的，强制升级
    public var MiniVersion: String?
    /// 失效的系统版本号
    public var ExpiredOSVersion: String?
    /// 失效的日期, 格式： yyyy-MM-dd
    public var ExpiredDate: String?
    /// 有新版本，就强制升级
    public var ForceUpdateToTheLatest: Bool?
    
    /// json格式的字符串
    public func toJsonString() -> String {
        let json: [String: Any] = [
            "Name": Name ?? "",
            "BundleId": BundleId ?? "",
            "MiniVersion": MiniVersion ?? "",
            "ExpiredOSVersion": ExpiredOSVersion ?? "",
            "ExpiredDate": ExpiredDate ?? "",
            "ForceUpdateToTheLatest": ForceUpdateToTheLatest ?? false
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}

extension YLUpdateXMLModel {
    /// 使用独立的 XMLDocument 解析配置，不保留上次请求的数据。
    static func parse(data: Data) throws -> YLUpdateXMLModel? {
        let document = try XMLDocument(data: data, options: [.nodeLoadExternalEntitiesNever])
        guard let root = document.rootElement() else { return nil }
        
        func text(_ name: String) -> String? {
            root.elements(forName: name).first?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var update = YLUpdateXMLModel()
        update.Name = text("Name")
        update.BundleId = text("BundleId")
        update.MiniVersion = text("MiniVersion")
        update.ExpiredDate = text("ExpiredDate")
        update.ExpiredOSVersion = text("ExpiredOSVersion")
        switch text("ForceUpdateToTheLatest")?.lowercased() {
        case "true", "1": update.ForceUpdateToTheLatest = true
        case "false", "0": update.ForceUpdateToTheLatest = false
        default: update.ForceUpdateToTheLatest = nil
        }
        return update
    }
}
