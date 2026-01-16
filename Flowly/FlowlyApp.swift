//
//  FlowlyApp.swift
//  Flowly
//
//  Main app entry point
//

import SwiftUI
import AppKit

@main
struct FlowlyApp: App {
    @StateObject private var eventTapObservable: ScrollEventTapObservable
    @StateObject private var licenseManager = LicenseManager.shared

    init() {
        let observable = ScrollEventTapObservable(eventTap: ScrollEventTap())
        _eventTapObservable = StateObject(wrappedValue: observable)

        // Start the event tap when app launches (if licensed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if LicenseManager.shared.isFeatureEnabled {
                observable.start()
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("Flowly", systemImage: "arrow.up.and.down.text.horizontal") {
            MenuBarView(eventTap: eventTapObservable.eventTap)
                .environmentObject(licenseManager)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(eventTap: eventTapObservable)
                .environmentObject(licenseManager)
        }
    }
}

