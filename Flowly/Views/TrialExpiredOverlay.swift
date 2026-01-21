//
//  TrialExpiredOverlay.swift
//  Flowly
//
//  Overlay shown when trial expires to block settings access
//

import SwiftUI

struct TrialExpiredOverlay: View {
    @ObservedObject var licenseManager = LicenseManager.shared

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

                    LicenseActivationForm(
                        licenseManager: licenseManager,
                        textFieldWidth: 200,
                        showPurchaseButton: false
                    )
                }
            }
            .padding(40)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(radius: 20)
        }
    }
}
