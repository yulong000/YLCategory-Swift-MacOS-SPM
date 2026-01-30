//
//  NSTextField+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/23.
//

import Foundation
import AppKit

public extension NSTextField {
    
    /// 固定最大宽度，高度自适应
    @discardableResult
    func sizeWith(maxWidth: CGFloat) -> NSSize {
        let size = sizeThatFits(NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return size
    }
    
    /// 固定最大宽度，高度自适应
    @discardableResult
    func sizeToFit(maxWidth: CGFloat) -> Self {
        let size = sizeThatFits(NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
        return self
    }
    
    /// 构造一个文本
    convenience init(title: String,
                     wrapper: Bool = false,
                     font: NSFont? = nil,
                     textColor: NSColor? = nil,
                     alignment: NSTextAlignment = .left,
                     lineBreakMode: NSLineBreakMode = .byWordWrapping,
                     isSelectable: Bool? = nil) {
        if wrapper {
            self.init(wrappingLabelWithString: title)
        } else {
            self.init(labelWithString: title)
        }
        self.textColor = textColor
        self.font = font
        self.alignment = alignment
        self.lineBreakMode = lineBreakMode
        if let isSelectable = isSelectable {
            self.isSelectable = isSelectable
        }
    }
    
    /// 构造一个输入框
    convenience init(placeholder: String, delegate: NSTextFieldDelegate? = nil) {
        self.init()
        self.placeholderString = placeholder
        self.delegate = delegate
    }
}
