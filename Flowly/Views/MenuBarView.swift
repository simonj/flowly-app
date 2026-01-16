//
//  MenuBarView.swift
//  Flowly
//
//  Menu bar dropdown content
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @EnvironmentObject var licenseManager: LicenseManager
    let eventTap: ScrollEventTap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusText)
                    .font(.caption)
                Spacer()
                licenseStatusBadge
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

    // MARK: - Status Helpers

    private var statusColor: Color {
        if !licenseManager.isFeatureEnabled {
            return .orange
        }
        return eventTap.hasAccessibilityPermission ? .green : .red
    }

    private var statusText: String {
        if !licenseManager.isFeatureEnabled {
            return "License Required"
        }
        return eventTap.hasAccessibilityPermission ? "Active" : "Permission Required"
    }

    @ViewBuilder
    private var licenseStatusBadge: some View {
        switch licenseManager.status {
        case .trial(let daysRemaining):
            Text("\(daysRemaining)d trial")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(4)
        case .licensed:
            Text("Licensed")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(4)
        case .expired:
            Text("Expired")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(4)
        case .validating:
            EmptyView()
        }
    }
}
