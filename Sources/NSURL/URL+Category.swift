//
//  URL+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/2/2.
//

import Foundation

public extension URL {
    
    /// 目录不存在时创建
    func createDirIfNeeded() {
        guard isFileURL else { return }
        
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(at: self, withIntermediateDirectories: true)
            } catch {
                print("create dir '\(self)' error: \(error)")
            }
        }
    }
    
    /// 创建目录，如果存在，就替换
    func createOrReplaceDirectory() {
        guard isFileURL else { return }
        
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            do {
                try fm.removeItem(at: self)
            } catch {
                print("remove dir '\(self)' error: \(error)")
            }
        }
        do {
            try fm.createDirectory(at: self, withIntermediateDirectories: true)
        } catch {
            print("create dir '\(self)' error: \(error)")
        }
    }
    
    /// 创建文件，如果存在，就替换
    /// - Parameters:
    ///   - contents: 文件内容
    ///   - attributes: 文件属性
    func createOrReplaceFile(contents: Data? = nil, attributes: [FileAttributeKey: Any]? = nil) {
        guard isFileURL else { return }
        
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            do {
                try fm.removeItem(at: self)
            } catch {
                print("remove file '\(self)' error: \(error)")
            }
        }
        if !fm.createFile(atPath: path, contents: contents, attributes: attributes) {
            print("create file '\(self)' failed")
        }
    }
}
