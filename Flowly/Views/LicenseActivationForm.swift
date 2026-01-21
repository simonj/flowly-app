//
//  LicenseActivationForm.swift
//  Flowly
//
//  Reusable license activation form component
//

import SwiftUI

struct LicenseActivationForm: View {
    @ObservedObject var licenseManager: LicenseManager
    @State private var emailInput: String = ""
    @State private var isActivating: Bool = false

    let textFieldWidth: CGFloat?
    let showPurchaseButton: Bool
    let buttonStyle: ActivateButtonStyle

    enum ActivateButtonStyle {
        case bordered
        case borderedProminent
    }

    init(
        licenseManager: LicenseManager = .shared,
        textFieldWidth: CGFloat? = nil,
        showPurchaseButton: Bool = true,
        buttonStyle: ActivateButtonStyle = .bordered
    ) {
        self.licenseManager = licenseManager
        self.textFieldWidth = textFieldWidth
        self.showPurchaseButton = showPurchaseButton
        self.buttonStyle = buttonStyle
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("email@example.com", text: $emailInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: textFieldWidth)
                    .disabled(isActivating)

                activateButton
            }

            if let error = licenseManager.validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if showPurchaseButton {
                Button(action: { licenseManager.openPurchasePage() }) {
                    Label("Purchase License", systemImage: "cart.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    @ViewBuilder
    private var activateButton: some View {
        Button(action: activateLicense) {
            if isActivating {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Text("Activate")
            }
        }
        .disabled(emailInput.isEmpty || isActivating)
        .modifier(ActivateButtonStyleModifier(style: buttonStyle))
    }

    private func activateLicense() {
        isActivating = true
        licenseManager.activateLicense(email: emailInput)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isActivating = false
        }
    }
}

private struct ActivateButtonStyleModifier: ViewModifier {
    let style: LicenseActivationForm.ActivateButtonStyle

    func body(content: Content) -> some View {
        switch style {
        case .bordered:
            content.buttonStyle(.bordered)
        case .borderedProminent:
            content.buttonStyle(.borderedProminent)
        }
    }
}
