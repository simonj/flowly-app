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
    @State private var hoveredButton: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header with app name and icon
            VStack(spacing: 8) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                Text("Flowly")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                // Status indicator with better styling
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                        .shadow(color: statusColor.opacity(0.5), radius: 2)
                    Text(statusText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.1))
                )

                if case .licensed = licenseManager.status {
                    // Don't show badge when licensed
                } else {
                    licenseStatusBadge
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 12)

            // Menu items
            VStack(spacing: 2) {
                // Settings button
                if #available(macOS 14, *) {
                    SettingsLink {
                        MenuButtonContent(
                            icon: "gear",
                            title: "Settings",
                            isHovered: hoveredButton == "settings"
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .onHover { hovering in
                        hoveredButton = hovering ? "settings" : nil
                    }
                } else {
                    MenuButton(
                        icon: "gear",
                        title: "Settings",
                        isHovered: hoveredButton == "settings"
                    ) {
                        openSettingsWindowFallback()
                    }
                    .onHover { hovering in
                        hoveredButton = hovering ? "settings" : nil
                    }
                }

                // Quit button
                MenuButton(
                    icon: "power",
                    title: "Quit Flowly",
                    isHovered: hoveredButton == "quit",
                    isDestructive: true
                ) {
                    NSApplication.shared.terminate(nil)
                }
                .onHover { hovering in
                    hoveredButton = hovering ? "quit" : nil
                }
            }
            .padding(.vertical, 8)
        }
        .frame(width: 240)
        .background(
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(nsColor: .controlBackgroundColor),
                        Color(nsColor: .controlBackgroundColor).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Subtle texture overlay
                Color.white.opacity(0.02)
            }
        )
    }

    private func openSettingsWindowFallback() {
        // For macOS 13, use the legacy method
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
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
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text("\(daysRemaining) days left in trial")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.orange.opacity(0.15))
            )
        case .expired:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 10))
                Text("Trial expired")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(0.15))
            )
        case .licensed, .validating:
            EmptyView()
        }
    }
}

// MARK: - Menu Button Components

struct MenuButtonContent: View {
    let icon: String
    let title: String
    let isHovered: Bool
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 16)
                .foregroundColor(isDestructive ? .red : .primary)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isDestructive ? .red : .primary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let isHovered: Bool
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MenuButtonContent(
                icon: icon,
                title: title,
                isHovered: isHovered,
                isDestructive: isDestructive
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}
