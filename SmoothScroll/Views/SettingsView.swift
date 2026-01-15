//
//  SettingsView.swift
//  SmoothScroll
//
//  Settings window UI
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @ObservedObject var eventTap: ScrollEventTapObservable
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "arrow.up.and.down.text.horizontal")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                Text("SmoothScroll")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.top, 20)
            
            Divider()
            
            // Accessibility Permission Status
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: eventTap.hasPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(eventTap.hasPermission ? .green : .orange)
                    Text("Accessibility Permission")
                        .font(.headline)
                }
                
                if eventTap.hasPermission {
                    Text("Smooth scrolling is active and working.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accessibility permission is required for smooth scrolling to work.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Open System Settings") {
                            eventTap.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Divider()
            
            // Animation Duration Setting
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Animation Duration")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(settingsManager.animationDuration)) ms")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                
                Slider(
                    value: $settingsManager.animationDuration,
                    in: 50...500,
                    step: 10
                )
                
                HStack {
                    Text("50 ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("500 ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Higher values create smoother but slower scrolling. Lower values are faster but less smooth.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Spacer()
            
            // Reset button
            Button("Reset to Defaults") {
                settingsManager.resetToDefaults()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .frame(width: 400, height: 500)
        .padding()
    }
}

// Observable wrapper for ScrollEventTap to use in SwiftUI
class ScrollEventTapObservable: ObservableObject {
    let eventTap: ScrollEventTap
    @Published var hasPermission: Bool = false
    
    init(eventTap: ScrollEventTap) {
        self.eventTap = eventTap
        self.hasPermission = eventTap.hasAccessibilityPermission
        updatePermissionStatus()
    }
    
    func requestPermission() {
        eventTap.requestAccessibilityPermission()
        // Check again after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updatePermissionStatus()
        }
    }
    
    func updatePermissionStatus() {
        hasPermission = eventTap.hasAccessibilityPermission
    }
    
    func start() {
        _ = eventTap.start()
        updatePermissionStatus()
    }
}

