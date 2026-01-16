//
//  MenuBarView.swift
//  Flowly
//
//  Menu bar dropdown content
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    let eventTap: ScrollEventTap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status
            HStack {
                Circle()
                    .fill(eventTap.hasAccessibilityPermission ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(eventTap.hasAccessibilityPermission ? "Active" : "Permission Required")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Settings - use SettingsLink for macOS 14+, fallback for 13
            if #available(macOS 14, *) {
                SettingsLink {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            } else {
                Button(action: openSettingsWindow) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }

            Divider()

            // Quit
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label("Quit", systemImage: "xmark.circle")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .frame(width: 200)
        .padding(.vertical, 8)
    }

    private func openSettingsWindow() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
