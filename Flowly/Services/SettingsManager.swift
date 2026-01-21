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

    private static func loadDouble(from defaults: UserDefaults, key: String, defaultValue: Double) -> Double {
        defaults.object(forKey: key) != nil ? defaults.double(forKey: key) : defaultValue
    }

    private static func loadBool(from defaults: UserDefaults, key: String, defaultValue: Bool) -> Bool {
        defaults.object(forKey: key) != nil ? defaults.bool(forKey: key) : defaultValue
    }

    private init() {
        let d = defaults
        self.stepSize = Self.loadDouble(from: d, key: Keys.stepSize, defaultValue: 90.0)
        self.animationTime = Self.loadDouble(from: d, key: Keys.animationTime, defaultValue: 360.0)
        self.accelerationDelta = Self.loadDouble(from: d, key: Keys.accelerationDelta, defaultValue: 70.0)
        self.accelerationScale = Self.loadDouble(from: d, key: Keys.accelerationScale, defaultValue: 7.0)
        self.pulseScale = Self.loadDouble(from: d, key: Keys.pulseScale, defaultValue: 4.0)
        self.autoStartOnLogin = d.bool(forKey: Keys.autoStartOnLogin)
        self.animationEasingEnabled = Self.loadBool(from: d, key: Keys.animationEasingEnabled, defaultValue: true)
        self.standardWheelDirection = Self.loadBool(from: d, key: Keys.standardWheelDirection, defaultValue: true)
        self.horizontalScrollingEnabled = Self.loadBool(from: d, key: Keys.horizontalScrollingEnabled, defaultValue: true)
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
