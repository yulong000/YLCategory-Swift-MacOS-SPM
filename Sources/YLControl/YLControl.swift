//
//  YLControl.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation
import AppKit

open class YLControl: NSControl {
    
    // 自定义NSControl时，为了响应点击事件，需要实现下面的方法
    
    private var isTrackingClick = false

    open override func mouseDown(with event: NSEvent) {
        guard isEnabled else {
            super.mouseDown(with: event)
            return
        }
        let p = convert(event.locationInWindow, from: nil)
        isTrackingClick = bounds.contains(p)
        if isTrackingClick {
            window?.makeFirstResponder(self)
        }
        super.mouseDown(with: event)
    }

    open override func mouseDragged(with event: NSEvent) {
        guard isTrackingClick else {
            super.mouseDragged(with: event)
            return
        }
        let p = convert(event.locationInWindow, from: nil)
        isTrackingClick = bounds.contains(p)
        super.mouseDragged(with: event)
    }

    open override func mouseUp(with event: NSEvent) {
        defer {
            isTrackingClick = false
            super.mouseUp(with: event)
        }
        guard isEnabled, isTrackingClick, let action = action else { return }
        let p = convert(event.locationInWindow, from: nil)
        guard bounds.contains(p) else { return }
        NSApp.sendAction(action, to: target, from: self)
    }
    
    open override var acceptsFirstResponder: Bool { true }
    open override func becomeFirstResponder() -> Bool { true }
    open override var isFlipped: Bool { true }

}
