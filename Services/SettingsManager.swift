//
//  SettingsManager.swift
//  SmoothScroll
//
//  Manages user preferences using UserDefaults
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let animationDurationKey = "animationDuration"
    private let defaults = UserDefaults.standard
    
    @Published var animationDuration: Double {
        didSet {
            defaults.set(animationDuration, forKey: animationDurationKey)
        }
    }
    
    private init() {
        // Default: 200ms
        self.animationDuration = defaults.double(forKey: animationDurationKey)
        if animationDuration == 0 {
            animationDuration = 200.0
        }
    }
    
    func resetToDefaults() {
        animationDuration = 200.0
    }
}

