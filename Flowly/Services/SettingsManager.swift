//
//  SettingsManager.swift
//  Flowly
//
//  Manages user preferences using UserDefaults
//

import Foundation
import Combine
import ServiceManagement

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let stepSize = "stepSize"
        static let animationTime = "animationTime"
        static let accelerationDelta = "accelerationDelta"
        static let accelerationScale = "accelerationScale"
        static let pulseScale = "pulseScale"
        static let autoStartOnLogin = "autoStartOnLogin"
        static let animationEasingEnabled = "animationEasingEnabled"
        static let standardWheelDirection = "standardWheelDirection"
        static let horizontalScrollingEnabled = "horizontalScrollingEnabled"
    }

    // MARK: - Settings Properties

    /// Step size in pixels (default: 90)
    @Published var stepSize: Double {
        didSet {
            let clamped = max(10, min(300, stepSize))
            if stepSize != clamped { stepSize = clamped }
            defaults.set(clamped, forKey: Keys.stepSize)
        }
    }

    /// Animation time in milliseconds (default: 360)
    @Published var animationTime: Double {
        didSet {
            let clamped = max(50, min(1000, animationTime))
            if animationTime != clamped { animationTime = clamped }
            defaults.set(clamped, forKey: Keys.animationTime)
        }
    }

    /// Acceleration delta in milliseconds - time threshold for detecting rapid scrolling (default: 70)
    @Published var accelerationDelta: Double {
        didSet {
            let clamped = max(10, min(200, accelerationDelta))
            if accelerationDelta != clamped { accelerationDelta = clamped }
            defaults.set(clamped, forKey: Keys.accelerationDelta)
        }
    }

    /// Acceleration scale multiplier when scrolling rapidly (default: 7)
    @Published var accelerationScale: Double {
        didSet {
            let clamped = max(1, min(20, accelerationScale))
            if accelerationScale != clamped { accelerationScale = clamped }
            defaults.set(clamped, forKey: Keys.accelerationScale)
        }
    }

    /// Pulse scale - affects the easing curve intensity (default: 4)
    @Published var pulseScale: Double {
        didSet {
            let clamped = max(1, min(10, pulseScale))
            if pulseScale != clamped { pulseScale = clamped }
            defaults.set(clamped, forKey: Keys.pulseScale)
        }
    }

    /// Auto start on login (default: false)
    @Published var autoStartOnLogin: Bool {
        didSet {
            defaults.set(autoStartOnLogin, forKey: Keys.autoStartOnLogin)
            updateLoginItem()
        }
    }

    /// Animation easing enabled (default: true)
    @Published var animationEasingEnabled: Bool {
        didSet {
            defaults.set(animationEasingEnabled, forKey: Keys.animationEasingEnabled)
        }
    }

    /// Standard wheel direction - false inverts scroll direction (default: true)
    @Published var standardWheelDirection: Bool {
        didSet {
            defaults.set(standardWheelDirection, forKey: Keys.standardWheelDirection)
        }
    }

    /// Horizontal smooth scrolling enabled (default: true)
    @Published var horizontalScrollingEnabled: Bool {
        didSet {
            defaults.set(horizontalScrollingEnabled, forKey: Keys.horizontalScrollingEnabled)
        }
    }

    // MARK: - Initialization

    private init() {
        // Load saved values or use defaults
        self.stepSize = defaults.object(forKey: Keys.stepSize) != nil
            ? defaults.double(forKey: Keys.stepSize) : 90.0

        self.animationTime = defaults.object(forKey: Keys.animationTime) != nil
            ? defaults.double(forKey: Keys.animationTime) : 360.0

        self.accelerationDelta = defaults.object(forKey: Keys.accelerationDelta) != nil
            ? defaults.double(forKey: Keys.accelerationDelta) : 70.0

        self.accelerationScale = defaults.object(forKey: Keys.accelerationScale) != nil
            ? defaults.double(forKey: Keys.accelerationScale) : 7.0

        self.pulseScale = defaults.object(forKey: Keys.pulseScale) != nil
            ? defaults.double(forKey: Keys.pulseScale) : 4.0

        self.autoStartOnLogin = defaults.bool(forKey: Keys.autoStartOnLogin)

        self.animationEasingEnabled = defaults.object(forKey: Keys.animationEasingEnabled) != nil
            ? defaults.bool(forKey: Keys.animationEasingEnabled) : true

        self.standardWheelDirection = defaults.object(forKey: Keys.standardWheelDirection) != nil
            ? defaults.bool(forKey: Keys.standardWheelDirection) : true

        self.horizontalScrollingEnabled = defaults.object(forKey: Keys.horizontalScrollingEnabled) != nil
            ? defaults.bool(forKey: Keys.horizontalScrollingEnabled) : true
    }

    // MARK: - Methods

    func resetToDefaults() {
        stepSize = 90.0
        animationTime = 360.0
        accelerationDelta = 70.0
        accelerationScale = 7.0
        pulseScale = 4.0
        autoStartOnLogin = false
        animationEasingEnabled = true
        standardWheelDirection = true
        horizontalScrollingEnabled = true
    }

    private func updateLoginItem() {
        if #available(macOS 13.0, *) {
            do {
                if autoStartOnLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Silently ignore - this fails in test environments and sandboxed contexts
            }
        }
    }
}
