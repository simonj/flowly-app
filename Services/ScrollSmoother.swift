//
//  ScrollSmoother.swift
//  SmoothScroll
//
//  Smooths scroll events by breaking them into smaller increments
//

import Foundation
import CoreGraphics

class ScrollSmoother {
    private let settingsManager: SettingsManager
    private var activeAnimations: [UUID: DispatchWorkItem] = [:]
    private let queue = DispatchQueue(label: "com.smoothscroll.smoother", qos: .userInteractive)
    
    init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
    }
    
    func smoothScroll(deltaY: Double, deltaX: Double) {
        let animationId = UUID()
        let duration = settingsManager.animationDuration / 1000.0 // Convert ms to seconds
        
        // Cancel any existing animations
        cancelAllAnimations()
        
        // Calculate number of steps (aim for ~60fps)
        let steps = max(1, Int(duration * 60))
        let stepDuration = duration / Double(steps)
        
        // Use easing function for natural feel (ease-out)
        var currentStep = 0
        
        func scheduleNextStep() {
            guard currentStep < steps else { return }
            
            let progress = Double(currentStep + 1) / Double(steps)
            // Ease-out curve: 1 - (1 - t)^2
            let previousProgress = Double(currentStep) / Double(steps)
            let easedPrevious = 1.0 - pow(1.0 - previousProgress, 2.0)
            let easedCurrent = 1.0 - pow(1.0 - progress, 2.0)
            
            // Calculate incremental delta for this step
            let stepDeltaY = deltaY * (easedCurrent - easedPrevious)
            let stepDeltaX = deltaX * (easedCurrent - easedPrevious)
            
            // Create and post scroll event
            if let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(stepDeltaY), wheel2: Int32(stepDeltaX), wheel3: 0) {
                event.post(tap: .cghidEventTap)
            }
            
            currentStep += 1
            
            if currentStep < steps {
                let workItem = DispatchWorkItem {
                    scheduleNextStep()
                }
                activeAnimations[animationId] = workItem
                queue.asyncAfter(deadline: .now() + stepDuration, execute: workItem)
            } else {
                activeAnimations.removeValue(forKey: animationId)
            }
        }
        
        // Start the animation
        scheduleNextStep()
    }
    
    private func cancelAllAnimations() {
        queue.sync {
            for (_, workItem) in activeAnimations {
                workItem.cancel()
            }
            activeAnimations.removeAll()
        }
    }
    
    func cancelAnimations() {
        cancelAllAnimations()
    }
}

