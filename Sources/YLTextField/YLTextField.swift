//
//  YLTextField.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Cocoa

open class YLTextField: NSTextField, NSTextFieldDelegate {

    /// 是否支持换行
    open var lineFeed = false {
        didSet { cell?.isScrollable = !lineFeed }
    }
    /// 正则匹配, 只能输入匹配的字符 比如 #"^[a-zA-Z]+$"#
    open var matchesRegexString: String?
    
    /// 开始编辑
    open var beginEditHandler: (() -> Void)?
    /// 输入字符回调
    open var changedHandler: ((String) -> Void)?
    /// 结束编辑
    open var endEditHandler: ((String) -> Void)?
    

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = YLTextFieldCell()
        self.isEditable = true
        self.delegate = self
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cell = YLTextFieldCell()
        self.isEditable = true
        self.delegate = self
    }
    
    public override func becomeFirstResponder() -> Bool {
        beginEditHandler?()
        return super.becomeFirstResponder()
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        guard let input = obj.object as? NSTextField, input === self else {
            return
        }
        
        if let regex = matchesRegexString,
           let allowedRegex = try? NSRegularExpression(pattern: regex) {
            // 遍历每个字符，构建合法字符串
            let text = input.stringValue
            let filtered = text.filter { char in
                let str = String(char)
                let range = NSRange(location: 0, length: str.utf16.count)
                return allowedRegex.firstMatch(in: str, options: [], range: range) != nil
            }
            if text != String(filtered) {
                input.stringValue = String(filtered)
            }
        }
        
        changedHandler?(input.stringValue)
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        guard let input = obj.object as? NSTextField, input === self else {
            return
        }
        
        endEditHandler?(input.stringValue)
    }

}

open class YLSecureTextField: NSSecureTextField, NSTextFieldDelegate {
    
    /// 是否支持换行
    open var lineFeed = false {
        didSet { cell?.isScrollable = !lineFeed }
    }
    /// 正则匹配, 只能输入匹配的字符 比如 #"^[a-zA-Z]+$"#
    open var matchesRegexString: String?
    
    /// 开始编辑
    open var beginEditHandler: (() -> Void)?
    /// 输入字符回调
    open var changedHandler: ((String) -> Void)?
    /// 结束编辑
    open var endEditHandler: ((String) -> Void)?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = YLSecureTextFieldCell()
        self.isEditable = true
        self.delegate = self
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cell = YLSecureTextFieldCell()
        self.isEditable = true
        self.delegate = self
    }
    
    public override func becomeFirstResponder() -> Bool {
        beginEditHandler?()
        return super.becomeFirstResponder()
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        guard let input = obj.object as? NSTextField, input === self else {
            return
        }
        
        if let regex = matchesRegexString,
           let allowedRegex = try? NSRegularExpression(pattern: regex) {
            // 遍历每个字符，构建合法字符串
            let text = input.stringValue
            let filtered = text.filter { char in
                let str = String(char)
                let range = NSRange(location: 0, length: str.utf16.count)
                return allowedRegex.firstMatch(in: str, options: [], range: range) != nil
            }
            if text != String(filtered) {
                input.stringValue = String(filtered)
            }
        }
        
        changedHandler?(input.stringValue)
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        guard let input = obj.object as? NSTextField, input === self else {
            return
        }
        
        endEditHandler?(input.stringValue)
    }
}


fileprivate class YLTextFieldCell : NSTextFieldCell {
    
    override init(textCell string: String) {
        super.init(textCell: string)
        self.isScrollable = true
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.isScrollable = true
    }
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect = super.drawingRect(forBounds: rect)
        let size = self.cellSize(forBounds: rect)
        if newRect.height > size.height {
            newRect.size.height = size.height
            newRect.origin.y += (rect.height - size.height) / 2
        }
        return newRect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let newRect = self.isScrollable ? self.drawingRect(forBounds: rect) : rect
        super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let newRect = self.isScrollable ? self.drawingRect(forBounds: rect) : rect
        super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    override func hitTest(for event: NSEvent, in cellFrame: NSRect, of controlView: NSView) -> NSCell.HitResult {
        return .editableTextArea
    }
}

fileprivate final class YLSecureTextFieldCell: NSSecureTextFieldCell {
    
    override init(textCell string: String) {
        super.init(textCell: string)
        self.isScrollable = true
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.isScrollable = true
    }
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect = super.drawingRect(forBounds: rect)
        let size = cellSize(forBounds: rect)
        if newRect.height > size.height {
            newRect.size.height = size.height
            newRect.origin.y += (rect.height - size.height) / 2
        }
        return newRect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let newRect = isScrollable ? drawingRect(forBounds: rect) : rect
        super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let newRect = isScrollable ? drawingRect(forBounds: rect) : rect
        super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    override func hitTest(for event: NSEvent, in cellFrame: NSRect, of controlView: NSView) -> NSCell.HitResult {
        .editableTextArea
    }
}
