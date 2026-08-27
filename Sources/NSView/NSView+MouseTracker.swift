//
//  NSView+MouseTracker.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/8/23.
//

import AppKit
import ObjectiveC.runtime

/// 鼠标跟踪阶段
public enum YLMouseTrackingPhase {
    case entered
    case moved
    case exited
    case cancelled
}

/// 鼠标跟踪事件回调
public typealias YLMouseTrackingHandler = (_ sender: NSView, _ phase: YLMouseTrackingPhase, _ event: NSEvent) -> Void

nonisolated(unsafe) private var YLMouseTrackerKey: UInt8 = 0

private final class YLMouseTracker: NSResponder {
    
    private weak var view: NSView?
    
    private var handler: YLMouseTrackingHandler?
    private let options: NSTrackingArea.Options
    private var trackingArea: NSTrackingArea?
    
    init(view: NSView, options: NSTrackingArea.Options, handler: @escaping YLMouseTrackingHandler) {
        self.view = view
        self.handler = handler
        self.options = options
        super.init()
        addMouseTracking()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMouseTracking() {
        guard let view else { return }
        
        // 确保传入的options有效
        let eventOptions: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .mouseMoved,
            .cursorUpdate
        ]
        assert(!options.intersection(eventOptions).isEmpty, "NSTrackingArea.Options 至少需要包含一种鼠标事件类型")
        
        let area = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        view.addTrackingArea(area)
        trackingArea = area
    }
    
    func removeMouseTracking() {
        if let trackingArea {
            view?.removeTrackingArea(trackingArea)
            self.trackingArea = nil
        }
        handler = nil
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard let view else { return }
        handler?(view, .entered, event)
    }
    
    override func mouseExited(with event: NSEvent) {
        guard let view else { return }
        handler?(view, .exited, event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        guard let view else { return }
        handler?(view, .moved, event)
    }
    
    override func mouseCancelled(with event: NSEvent) {
        guard let view else { return }
        handler?(view, .cancelled, event)
    }
    
    deinit {
        removeMouseTracking()
    }
    
}

public extension NSView {
    
    func setMouseTracking(
        options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInKeyWindow,
            .inVisibleRect
        ],
        handler: @escaping YLMouseTrackingHandler) {
            removeMouseTracking()
            let tracker = YLMouseTracker(view: self, options: options, handler: handler)
            objc_setAssociatedObject(self, &YLMouseTrackerKey, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    
    func removeMouseTracking() {
        let tracker = objc_getAssociatedObject(self, &YLMouseTrackerKey) as? YLMouseTracker
        tracker?.removeMouseTracking()
        objc_setAssociatedObject(self, &YLMouseTrackerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
