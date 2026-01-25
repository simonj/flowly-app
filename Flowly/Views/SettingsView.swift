//
//  SettingsView.swift
//  Flowly
//
//  Settings window UI
//

import SwiftUI

// MARK: - Flowly Brand Colors
extension Color {
    static let flowlyLime = Color(red: 201/255, green: 226/255, blue: 101/255)  // #C9E265
    static let flowlyPeach = Color(red: 248/255, green: 200/255, blue: 200/255) // #f8c8c8
    static let flowlyDark = Color(red: 30/255, green: 45/255, blue: 61/255)     // #1e2d3d
}

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @EnvironmentObject var licenseManager: LicenseManager
    @ObservedObject var eventTap: ScrollEventTapObservable
    @State private var showAdvanced = false

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
            .frame(width: 420, height: 420)

            // Show overlay when trial expired
            if case .expired = licenseManager.status {
                TrialExpiredOverlay()
            }
        }
    }

    private var settingsTab: some View {
        VStack(spacing: 10) {
            // Permission Status (compact)
            permissionSection

            // Scroll Smoothness Presets
            presetSection

            // Advanced Settings (collapsible)
            advancedSection

            // Options (2x2 grid)
            optionsSection

            Spacer(minLength: 0)

            // Reset button (subtle)
            Button(action: { settingsManager.resetToDefaults() }) {
                Text("Reset to Defaults")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 6)
        }
        .padding(12)
    }

    // MARK: - Sections

    private var permissionSection: some View {
        HStack(spacing: 10) {
            Image(systemName: eventTap.hasPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(eventTap.hasPermission ? .flowlyLime : .orange)
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 1) {
                Text(eventTap.hasPermission ? "Active" : "Permission Required")
                    .font(.subheadline.weight(.semibold))
                Text(eventTap.hasPermission
                     ? "Smooth scrolling is working"
                     : "Accessibility permission required")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !eventTap.hasPermission {
                Button("Open Settings") {
                    eventTap.requestPermission()
                }
                .buttonStyle(.borderedProminent)
                .tint(.flowlyLime)
                .controlSize(.small)
            }
        }
        .padding(10)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scroll Smoothness")
                .font(.subheadline.weight(.semibold))

            Picker("Preset", selection: $settingsManager.selectedPreset) {
                ForEach(ScrollPreset.allCases, id: \.self) { preset in
                    Text("\(preset.rawValue) – \(preset.description)")
                        .tag(preset)
                }
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
            .onChange(of: settingsManager.selectedPreset) { preset in
                settingsManager.applyPreset(preset)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureGroup("Advanced Settings", isExpanded: $showAdvanced) {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        settingRow(
                            title: "Step size",
                            value: "\(Int(settingsManager.stepSize)) px",
                            binding: $settingsManager.stepSize,
                            range: 10...300,
                            step: 5
                        )
                        settingRow(
                            title: "Animation time",
                            value: "\(Int(settingsManager.animationTime)) ms",
                            binding: $settingsManager.animationTime,
                            range: 50...1000,
                            step: 10
                        )
                    }

                    HStack(spacing: 12) {
                        settingRow(
                            title: "Accel. delta",
                            value: "\(Int(settingsManager.accelerationDelta)) ms",
                            binding: $settingsManager.accelerationDelta,
                            range: 10...200,
                            step: 5
                        )
                        settingRow(
                            title: "Accel. scale",
                            value: "\(Int(settingsManager.accelerationScale))x",
                            binding: $settingsManager.accelerationScale,
                            range: 1...20,
                            step: 1
                        )
                    }

                    settingRow(
                        title: "Easing intensity",
                        value: "\(Int(settingsManager.pulseScale))x",
                        binding: $settingsManager.pulseScale,
                        range: 1...10,
                        step: 1
                    )
                }
                .padding(.top, 6)
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(10)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Options")
                .font(.subheadline.weight(.semibold))

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    compactToggle("Auto start", isOn: $settingsManager.autoStartOnLogin)
                    compactToggle("Animation easing", isOn: $settingsManager.animationEasingEnabled)
                }
                GridRow {
                    compactToggle("Standard direction", isOn: $settingsManager.standardWheelDirection)
                    compactToggle("Horizontal scroll", isOn: $settingsManager.horizontalScrollingEnabled)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }

    // MARK: - Helper Views

    private func compactToggle(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.caption)
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .labelsHidden()
        }
        .frame(minWidth: 140)
    }

    private func settingRow(
        title: String,
        value: String,
        binding: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            Slider(value: binding, in: range, step: step)
                .controlSize(.small)
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
