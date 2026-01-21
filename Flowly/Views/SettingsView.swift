//
//  SettingsView.swift
//  Flowly
//
//  Settings window UI
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @EnvironmentObject var licenseManager: LicenseManager
    @ObservedObject var eventTap: ScrollEventTapObservable

    var body: some View {
        ZStack {
            TabView {
                settingsTab
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }

                LicenseView()
                    .tabItem {
                        Label("License", systemImage: "key.fill")
                    }
            }
            .frame(width: 450, height: 650)

            // Show overlay when trial expired
            if case .expired = licenseManager.status {
                TrialExpiredOverlay()
            }
        }
    }

    private var settingsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                headerSection

                Divider()

                // Permission Status
                permissionSection

                Divider()

                // Scroll Settings
                scrollSettingsSection

                Divider()

                // Acceleration Settings
                accelerationSettingsSection

                Divider()

                // Options
                optionsSection

                Divider()

                // Reset button
                Button("Reset to Defaults") {
                    settingsManager.resetToDefaults()
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 8)
            }
            .padding()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.and.down.text.horizontal")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("Flowly")
                .font(.title2)
                .fontWeight(.bold)
            Text("Preferences")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    private var permissionSection: some View {
        HStack {
            Image(systemName: eventTap.hasPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(eventTap.hasPermission ? .green : .orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(eventTap.hasPermission ? "Active" : "Permission Required")
                    .font(.headline)
                Text(eventTap.hasPermission
                     ? "Smooth scrolling is working"
                     : "Accessibility permission required")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !eventTap.hasPermission {
                Button("Open Settings") {
                    eventTap.requestPermission()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var scrollSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scroll Settings")
                .font(.headline)

            // Step Size
            settingRow(
                title: "Step size",
                value: "\(Int(settingsManager.stepSize)) px",
                binding: $settingsManager.stepSize,
                range: 10...300,
                step: 5
            )

            // Animation Time
            settingRow(
                title: "Animation time",
                value: "\(Int(settingsManager.animationTime)) ms",
                binding: $settingsManager.animationTime,
                range: 50...1000,
                step: 10
            )
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var accelerationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acceleration")
                .font(.headline)

            // Acceleration Delta
            settingRow(
                title: "Acceleration delta",
                value: "\(Int(settingsManager.accelerationDelta)) ms",
                binding: $settingsManager.accelerationDelta,
                range: 10...200,
                step: 5
            )

            // Acceleration Scale
            settingRow(
                title: "Acceleration scale",
                value: "\(Int(settingsManager.accelerationScale))x",
                binding: $settingsManager.accelerationScale,
                range: 1...20,
                step: 1
            )

            // Pulse Scale
            settingRow(
                title: "Pulse scale",
                value: "\(Int(settingsManager.pulseScale))x",
                binding: $settingsManager.pulseScale,
                range: 1...10,
                step: 1
            )
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.headline)

            Toggle("Auto start on login", isOn: $settingsManager.autoStartOnLogin)

            Toggle("Animation easing", isOn: $settingsManager.animationEasingEnabled)

            Toggle("Standard wheel direction", isOn: $settingsManager.standardWheelDirection)

            Toggle("Horizontal smooth scrolling", isOn: $settingsManager.horizontalScrollingEnabled)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Helper Views

    private func settingRow(
        title: String,
        value: String,
        binding: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .frame(width: 60, alignment: .trailing)
            }

            Slider(value: binding, in: range, step: step)
        }
    }
}

// Observable wrapper for ScrollEventTap to use in SwiftUI
class ScrollEventTapObservable: ObservableObject {
    let eventTap: ScrollEventTap
    @Published var hasPermission: Bool = false
    private var permissionCheckTimer: Timer?

    init(eventTap: ScrollEventTap) {
        self.eventTap = eventTap
        self.hasPermission = eventTap.hasAccessibilityPermission
        startPermissionMonitoring()
    }

    deinit {
        permissionCheckTimer?.invalidate()
    }

    private func startPermissionMonitoring() {
        // Check permission status every 2 seconds
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAndUpdatePermission()
        }
    }

    private func checkAndUpdatePermission() {
        let newStatus = eventTap.hasAccessibilityPermission
        if newStatus != hasPermission {
            DispatchQueue.main.async {
                self.hasPermission = newStatus
                // Try to start event tap when permission is granted
                if newStatus {
                    _ = self.eventTap.start()
                }
            }
        }
    }

    func requestPermission() {
        eventTap.requestAccessibilityPermission()
    }

    private func updatePermissionStatus() {
        hasPermission = eventTap.hasAccessibilityPermission
    }

    func start() {
        _ = eventTap.start()
        updatePermissionStatus()
    }
}
