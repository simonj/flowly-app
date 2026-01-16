//
//  TrialExpiredOverlay.swift
//  Flowly
//
//  Overlay shown when trial expires to block settings access
//

import SwiftUI

struct TrialExpiredOverlay: View {
    @ObservedObject var licenseManager = LicenseManager.shared
    @State private var emailInput: String = ""
    @State private var isActivating: Bool = false

    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Content
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                // Title
                Text("Trial Expired")
                    .font(.title)
                    .fontWeight(.bold)

                // Description
                Text("Your 7-day trial has ended.\nPurchase a license to continue using Flowly.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                // Purchase button
                Button(action: { licenseManager.openPurchasePage() }) {
                    Label("Purchase License", systemImage: "cart.fill")
                        .frame(width: 200)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Divider()
                    .frame(width: 300)

                // License activation
                VStack(spacing: 12) {
                    Text("Already have a license?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        TextField("Enter your email", text: $emailInput)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                            .disabled(isActivating)

                        Button(action: activateLicense) {
                            if isActivating {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Text("Activate")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(emailInput.isEmpty || isActivating)
                    }

                    if let error = licenseManager.validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(40)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(radius: 20)
        }
    }

    private func activateLicense() {
        isActivating = true
        licenseManager.activateLicense(email: emailInput)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isActivating = false
        }
    }
}
