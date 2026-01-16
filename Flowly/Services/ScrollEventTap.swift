//
//  ScrollEventTap.swift
//  Flowly
//
//  Intercepts scroll wheel events using CGEventTap
//

import Foundation
import CoreGraphics
import ApplicationServices

class ScrollEventTap {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let smoother: ScrollSmoother
    private let settingsManager: SettingsManager
    private var isEnabled = false

    init(smoother: ScrollSmoother = ScrollSmoother(), settingsManager: SettingsManager = .shared) {
        self.smoother = smoother
        self.settingsManager = settingsManager
    }

    func start() -> Bool {
        guard eventTap == nil else { return true }

        // Check accessibility permissions
        guard AXIsProcessTrusted() else {
            print("Accessibility permissions not granted")
            return false
        }

        // Create event tap
        let eventMask = (1 << CGEventType.scrollWheel.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let eventTap = Unmanaged<ScrollEventTap>.fromOpaque(refcon).takeUnretainedValue()
                return eventTap.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            print("Failed to create event tap")
            return false
        }

        // Create run loop source
        guard let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0) else {
            print("Failed to create run loop source")
            CGEvent.tapEnable(tap: eventTap, enable: false)
            self.eventTap = nil
            return false
        }

        self.runLoopSource = runLoopSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        isEnabled = true
        return true
    }

    func stop() {
        guard let eventTap = eventTap else { return }
        CGEvent.tapEnable(tap: eventTap, enable: false)
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        CFMachPortInvalidate(eventTap)
        self.eventTap = nil
        isEnabled = false
    }

    // Magic number to identify our synthetic events
    private static let syntheticEventMarker: Int64 = 0x534D4F4F54480000 // "SMOOTH" in hex

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .scrollWheel else {
            return Unmanaged.passUnretained(event)
        }

        // Check if this is our own synthetic event - pass it through
        let userData = event.getIntegerValueField(.eventSourceUserData)
        if userData == ScrollEventTap.syntheticEventMarker {
            return Unmanaged.passUnretained(event)
        }

        // Get scroll deltas
        var deltaY = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)
        var deltaX = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis2)

        // Skip if both deltas are essentially zero (threshold lowered to catch more events)
        guard abs(deltaY) > 0.1 || abs(deltaX) > 0.1 else {
            return Unmanaged.passUnretained(event)
        }

        // Apply wheel direction inversion if not using standard direction
        if !settingsManager.standardWheelDirection {
            deltaY = -deltaY
            deltaX = -deltaX
        }

        // Send to smoother
        smoother.smoothScroll(deltaY: deltaY, deltaX: deltaX)

        // Return nil to suppress the original event
        return nil
    }

    var hasAccessibilityPermission: Bool {
        return AXIsProcessTrusted()
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
