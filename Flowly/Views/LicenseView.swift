//
//  LicenseView.swift
//  Flowly
//
//  License management UI
//

import SwiftUI

struct LicenseView: View {
    @ObservedObject var licenseManager = LicenseManager.shared
    @State private var emailInput: String = ""
    @State private var isActivating: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Status Card
            statusCard

            // Action Section
            actionSection

            Spacer()
        }
        .padding()
        .frame(width: 450, height: 350)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        VStack(spacing: 12) {
            statusIcon
            statusTitle
            statusSubtitle
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(statusBackgroundColor)
        .cornerRadius(12)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch licenseManager.status {
        case .trial:
            Image(systemName: "clock.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)
        case .licensed:
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundColor(.green)
        case .expired:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(.red)
        case .validating:
            ProgressView()
                .scaleEffect(1.5)
        }
    }

    @ViewBuilder
    private var statusTitle: some View {
        switch licenseManager.status {
        case .trial(let daysRemaining):
            Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining")
                .font(.title2)
                .fontWeight(.semibold)
        case .licensed:
            Text("Licensed")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        case .expired:
            Text("Trial Expired")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.red)
        case .validating:
            Text("Validating...")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private var statusSubtitle: some View {
        switch licenseManager.status {
        case .trial:
            Text("Full features available during trial")
                .font(.subheadline)
                .foregroundColor(.secondary)
        case .licensed(let email):
            Text(email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        case .expired:
            Text("Purchase a license to continue using Flowly")
                .font(.subheadline)
                .foregroundColor(.secondary)
        case .validating:
            Text("Please wait...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var statusBackgroundColor: Color {
        switch licenseManager.status {
        case .trial:
            return Color.orange.opacity(0.1)
        case .licensed:
            return Color.green.opacity(0.1)
        case .expired:
            return Color.red.opacity(0.1)
        case .validating:
            return Color(.controlBackgroundColor)
        }
    }

    // MARK: - Action Section

    @ViewBuilder
    private var actionSection: some View {
        switch licenseManager.status {
        case .trial, .expired:
            activationSection
        case .licensed:
            deactivationSection
        case .validating:
            EmptyView()
        }
    }

    private var activationSection: some View {
        VStack(spacing: 16) {
            // Email input
            VStack(alignment: .leading, spacing: 6) {
                Text("Enter License Email")
                    .font(.headline)

                HStack {
                    TextField("email@example.com", text: $emailInput)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isActivating)

                    Button(action: activateLicense) {
                        if isActivating {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Text("Activate")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(emailInput.isEmpty || isActivating)
                }

                if let error = licenseManager.validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            // Purchase button
            Button(action: { licenseManager.openPurchasePage() }) {
                Label("Purchase License", systemImage: "cart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var deactivationSection: some View {
        VStack(spacing: 12) {
            Text("License is active on this device")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Deactivate License") {
                licenseManager.deactivate()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Actions

    private func activateLicense() {
        isActivating = true
        licenseManager.activateLicense(email: emailInput)

        // Reset activating state after a delay (validation is async)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isActivating = false
        }
    }
}
