//
//  YLUpdateXMLParserDelegate.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import Foundation

public class YLUpdateXMLParserDelegate: NSObject, XMLParserDelegate {
    
    public var update: YLUpdateXMLModel? = YLUpdateXMLModel()
    private var currentElement: String? = ""
    
    // MARK: 解析开始某个元素
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    // MARK: 读取元素内容
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let currentElement = currentElement else { return }
        switch currentElement {
        case "Name":                    update?.Name = string
        case "BundleId":                update?.BundleId = string
        case "ForceUpdateToTheLatest":  update?.ForceUpdateToTheLatest = Bool(string) ?? Bool(Int(string) == 0 ? "false" : "true")
        case "MiniVersion":             update?.MiniVersion = string
        case "ExpiredDate":             update?.ExpiredDate = string
        case "ExpiredOSVersion":        update?.ExpiredOSVersion = string
        default: break
        }
    }
    
    // MARK: 结束某个元素的解析
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = nil
    }
    
    // MARK: 解析完成
    public func parserDidEndDocument(_ parser: XMLParser) { }
    
    // MARK: 解析失败
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        update = nil
    }
}


public struct YLUpdateXMLModel {
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
    
    public func toJson() -> [String: Any] {
        return [
            "Name": Name ?? "",
            "BundleId": BundleId ?? "",
            "MiniVersion": MiniVersion ?? "",
            "ExpiredOSVersion": ExpiredOSVersion ?? "",
            "ExpiredDate": ExpiredDate ?? "",
            "ForceUpdateToTheLatest": ForceUpdateToTheLatest ?? false
        ]
    }
}
