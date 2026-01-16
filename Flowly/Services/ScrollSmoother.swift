//
//  ScrollSmoother.swift
//  Flowly
//
//  Smooths scroll events by breaking them into smaller increments
//

import Foundation
import CoreGraphics

class ScrollSmoother {
    private let settingsManager: SettingsManager
    private let queue = DispatchQueue(label: "com.flowly.smoother", qos: .userInteractive)

    // Animation state
    private var animationTimer: DispatchSourceTimer?
    private var targetDeltaY: Double = 0
    private var targetDeltaX: Double = 0
    private var currentProgress: Double = 0
    private var animationStartTime: CFAbsoluteTime = 0

    // Fractional remainder tracking to avoid pixel loss
    private var remainderY: Double = 0
    private var remainderX: Double = 0

    // Acceleration tracking
    private var lastScrollTime: CFAbsoluteTime = 0

    init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
    }

    func smoothScroll(deltaY: Double, deltaX: Double) {
        // Guard against NaN/Infinity from malformed CGEvent
        guard deltaY.isFinite && deltaX.isFinite else { return }

        // Clamp input to reasonable range (typical scroll delta is -10 to +10)
        let maxInputDelta = 500.0
        let clampedInputY = max(-maxInputDelta, min(maxInputDelta, deltaY))
        let clampedInputX = max(-maxInputDelta, min(maxInputDelta, deltaX))

        let now = CFAbsoluteTimeGetCurrent()
        let timeSinceLastScroll = (now - lastScrollTime) * 1000 // Convert to ms
        lastScrollTime = now

        // Apply step size scaling (normalize to step size)
        let stepSize = settingsManager.stepSize
        var scaledDeltaY = clampedInputY * (stepSize / 10.0) // Base factor
        var scaledDeltaX = clampedInputX * (stepSize / 10.0)

        // Apply acceleration if scrolling rapidly
        if timeSinceLastScroll < settingsManager.accelerationDelta && timeSinceLastScroll > 0 {
            let accelerationFactor = settingsManager.accelerationScale
            scaledDeltaY *= accelerationFactor
            scaledDeltaX *= accelerationFactor
        }

        // Clamp scaled values to prevent extreme deltas
        let maxScaledDelta = 10000.0
        scaledDeltaY = max(-maxScaledDelta, min(maxScaledDelta, scaledDeltaY))
        scaledDeltaX = max(-maxScaledDelta, min(maxScaledDelta, scaledDeltaX))

        // Check if horizontal scrolling is enabled
        if !settingsManager.horizontalScrollingEnabled {
            scaledDeltaX = 0
        }

        queue.async { [weak self] in
            self?.accumulateAndAnimate(deltaY: scaledDeltaY, deltaX: scaledDeltaX)
        }
    }

    private func accumulateAndAnimate(deltaY: Double, deltaX: Double) {
        // If animation is in progress, accumulate the new deltas
        if animationTimer != nil {
            // Calculate remaining delta from current animation
            let remainingFactor = 1.0 - currentProgress
            let remainingY = targetDeltaY * remainingFactor
            let remainingX = targetDeltaX * remainingFactor

            // Add new deltas to remaining
            targetDeltaY = remainingY + deltaY
            targetDeltaX = remainingX + deltaX
            currentProgress = 0
            animationStartTime = CFAbsoluteTimeGetCurrent()
        } else {
            // Start new animation
            targetDeltaY = deltaY
            targetDeltaX = deltaX
            currentProgress = 0
            animationStartTime = CFAbsoluteTimeGetCurrent()
            startAnimationTimer()
        }

        // Clamp accumulated targets to prevent unbounded growth
        let maxAccumulatedDelta = 50000.0
        targetDeltaY = max(-maxAccumulatedDelta, min(maxAccumulatedDelta, targetDeltaY))
        targetDeltaX = max(-maxAccumulatedDelta, min(maxAccumulatedDelta, targetDeltaX))
    }

    private func startAnimationTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        let frameInterval: Double = 1.0 / 60.0 // 60fps

        timer.schedule(deadline: .now(), repeating: frameInterval)
        timer.setEventHandler { [weak self] in
            self?.animationTick()
        }
        timer.resume()
        animationTimer = timer
    }

    private func animationTick() {
        let duration = settingsManager.animationTime / 1000.0 // Convert ms to seconds
        let elapsed = CFAbsoluteTimeGetCurrent() - animationStartTime
        let newProgress = min(1.0, elapsed / duration)

        // Calculate eased progress
        let previousEased = easeProgress(currentProgress)
        let currentEased = easeProgress(newProgress)
        let progressDelta = currentEased - previousEased

        // Calculate pixel deltas for this frame
        let rawDeltaY = targetDeltaY * progressDelta + remainderY
        let rawDeltaX = targetDeltaX * progressDelta + remainderX

        // Round to integers and track remainder
        let pixelDeltaY = round(rawDeltaY)
        let pixelDeltaX = round(rawDeltaX)
        remainderY = rawDeltaY - pixelDeltaY
        remainderX = rawDeltaX - pixelDeltaX

        // Clamp to Int32 range to prevent overflow (scroll deltas shouldn't be huge anyway)
        let maxDelta = Double(Int32.max - 1)
        let minDelta = Double(Int32.min + 1)
        let clampedDeltaY = max(minDelta, min(maxDelta, pixelDeltaY))
        let clampedDeltaX = max(minDelta, min(maxDelta, pixelDeltaX))

        // Post scroll event if there's movement
        if clampedDeltaY != 0 || clampedDeltaX != 0 {
            if let event = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,
                wheelCount: 2,
                wheel1: Int32(clampedDeltaY),
                wheel2: Int32(clampedDeltaX),
                wheel3: 0
            ) {
                // Mark as our synthetic event so it doesn't get re-intercepted
                event.setIntegerValueField(.eventSourceUserData, value: 0x534D4F4F54480000)
                event.post(tap: .cghidEventTap)
            }
        }

        currentProgress = newProgress

        // End animation when complete
        if currentProgress >= 1.0 {
            stopAnimationTimer()
            // Flush any remaining fractional pixels
            flushRemainder()
        }
    }

    func easeProgress(_ t: Double) -> Double {
        guard settingsManager.animationEasingEnabled else {
            return t // Linear
        }

        // Ease-out curve with pulse scale modifier
        // Higher pulse scale = more aggressive easing (faster start, slower end)
        let pulseScale = settingsManager.pulseScale
        let exponent = 1.0 + (pulseScale / 4.0) // Range: 1.25 to 3.5

        return 1.0 - pow(1.0 - t, exponent)
    }

    private func flushRemainder() {
        let pixelDeltaY = round(remainderY)
        let pixelDeltaX = round(remainderX)

        // Clamp to Int32 range
        let maxDelta = Double(Int32.max - 1)
        let minDelta = Double(Int32.min + 1)
        let clampedDeltaY = max(minDelta, min(maxDelta, pixelDeltaY))
        let clampedDeltaX = max(minDelta, min(maxDelta, pixelDeltaX))

        if clampedDeltaY != 0 || clampedDeltaX != 0 {
            if let event = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,
                wheelCount: 2,
                wheel1: Int32(clampedDeltaY),
                wheel2: Int32(clampedDeltaX),
                wheel3: 0
            ) {
                // Mark as our synthetic event so it doesn't get re-intercepted
                event.setIntegerValueField(.eventSourceUserData, value: 0x534D4F4F54480000)
                event.post(tap: .cghidEventTap)
            }
        }

        remainderY = 0
        remainderX = 0
    }

    private func stopAnimationTimer() {
        animationTimer?.cancel()
        animationTimer = nil
    }

    func cancelAnimations() {
        queue.async { [weak self] in
            self?.stopAnimationTimer()
            self?.targetDeltaY = 0
            self?.targetDeltaX = 0
            self?.currentProgress = 0
            self?.remainderY = 0
            self?.remainderX = 0
        }
    }
}
