//
//  LicenseManager.swift
//  Flowly
//
//  Manages license validation and trial tracking
//

import Foundation
import Combine
import AppKit

enum LicenseStatus: Equatable {
    case trial(daysRemaining: Int)
    case licensed(email: String)
    case expired
    case validating
}

class LicenseManager: ObservableObject {
    static let shared = LicenseManager()

    private let defaults = UserDefaults.standard
    private let trialDays = 7
    private let cacheValidityHours = 24

    // UserDefaults keys
    private enum Keys {
        static let trialStartDate = "licenseTrialStartDate"
        static let activatedEmail = "licenseActivatedEmail"
        static let lastValidationDate = "licenseLastValidationDate"
        static let lastValidationResult = "licenseLastValidationResult"
    }

    // API configuration
    private let validationURL = URL(string: "https://flowlyapp.dev/api/license/validate")!
    static let purchaseURL = URL(string: "https://flowlyapp.dev/pricing")!

    // MARK: - Published Properties

    @Published private(set) var status: LicenseStatus = .validating
    @Published private(set) var validationError: String?

    var isFeatureEnabled: Bool {
        switch status {
        case .trial(let daysRemaining):
            return daysRemaining > 0
        case .licensed:
            return true
        case .expired, .validating:
            return false
        }
    }

    var trialDaysRemaining: Int {
        if case .trial(let days) = status {
            return days
        }
        return 0
    }

    // MARK: - Initialization

    private init() {
        initializeTrialIfNeeded()
        refreshStatus()
    }

    // MARK: - Trial Management

    private func initializeTrialIfNeeded() {
        if defaults.object(forKey: Keys.trialStartDate) == nil {
            defaults.set(Date(), forKey: Keys.trialStartDate)
        }
    }

    private var trialStartDate: Date {
        defaults.object(forKey: Keys.trialStartDate) as? Date ?? Date()
    }

    private func calculateTrialDaysRemaining() -> Int {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
        return max(0, trialDays - daysSinceStart)
    }

    private var trialStatus: LicenseStatus {
        let daysRemaining = calculateTrialDaysRemaining()
        return daysRemaining > 0 ? .trial(daysRemaining: daysRemaining) : .expired
    }

    // MARK: - License Storage

    private var activatedEmail: String? {
        get { defaults.string(forKey: Keys.activatedEmail) }
        set { defaults.set(newValue, forKey: Keys.activatedEmail) }
    }

    private var lastValidationDate: Date? {
        get { defaults.object(forKey: Keys.lastValidationDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastValidationDate) }
    }

    private var lastValidationResult: Bool {
        get { defaults.bool(forKey: Keys.lastValidationResult) }
        set { defaults.set(newValue, forKey: Keys.lastValidationResult) }
    }

    private var isCacheValid: Bool {
        guard let lastValidation = lastValidationDate else { return false }
        let hoursSinceValidation = Calendar.current.dateComponents([.hour], from: lastValidation, to: Date()).hour ?? Int.max
        return hoursSinceValidation < cacheValidityHours
    }

    // MARK: - Status Management

    func refreshStatus() {
        if let email = activatedEmail {
            if isCacheValid && lastValidationResult {
                status = .licensed(email: email)
            } else {
                status = .validating
                validateLicense(email: email)
            }
        } else {
            status = trialStatus
        }
    }

    // MARK: - API Validation

    func activateLicense(email: String) {
        guard !email.isEmpty else {
            validationError = "Please enter an email address"
            return
        }

        validationError = nil
        status = .validating
        validateLicense(email: email, isActivation: true)
    }

    private func validateLicense(email: String, isActivation: Bool = false) {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.flowly.app"

        var request = URLRequest(url: validationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "bundleId": bundleId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleValidationResponse(
                    email: email,
                    data: data,
                    response: response,
                    error: error,
                    isActivation: isActivation
                )
            }
        }.resume()
    }

    private func handleValidationResponse(
        email: String,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        isActivation: Bool
    ) {
        // Network error - use cache if available
        if let error = error {
            if isCacheValid && activatedEmail == email {
                status = lastValidationResult ? .licensed(email: email) : .expired
            } else if isActivation {
                validationError = "Network error: \(error.localizedDescription)"
                restorePreValidationStatus()
            } else {
                restorePreValidationStatus()
            }
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            if isActivation {
                validationError = "Invalid server response"
            }
            restorePreValidationStatus()
            return
        }

        switch httpResponse.statusCode {
        case 200:
            // Parse response to check valid field
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let valid = json["valid"] as? Bool,
               valid {
                activatedEmail = email
                lastValidationDate = Date()
                lastValidationResult = true
                status = .licensed(email: email)
                validationError = nil
            } else {
                if isActivation {
                    validationError = "License validation failed"
                }
                lastValidationResult = false
                restorePreValidationStatus()
            }

        case 404:
            if isActivation {
                validationError = "No license found for this email"
            }
            lastValidationResult = false
            restorePreValidationStatus()

        case 403:
            if isActivation {
                validationError = "No valid purchase for this email"
            }
            lastValidationResult = false
            restorePreValidationStatus()

        default:
            if isActivation {
                validationError = "Server error (\(httpResponse.statusCode))"
            }
            restorePreValidationStatus()
        }
    }

    private func restorePreValidationStatus() {
        if let email = activatedEmail, isCacheValid, lastValidationResult {
            status = .licensed(email: email)
        } else {
            status = trialStatus
        }
    }

    // MARK: - Deactivation

    func deactivate() {
        activatedEmail = nil
        lastValidationDate = nil
        lastValidationResult = false
        validationError = nil
        refreshStatus()
    }

    // MARK: - Purchase

    func openPurchasePage() {
        NSWorkspace.shared.open(LicenseManager.purchaseURL)
    }
}
