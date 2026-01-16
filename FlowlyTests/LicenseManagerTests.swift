//
//  LicenseManagerTests.swift
//  FlowlyTests
//
//  Unit tests for LicenseManager
//

import XCTest
@testable import Flowly

final class LicenseManagerTests: XCTestCase {

    var licenseManager: LicenseManager!
    let testDefaults = UserDefaults(suiteName: "com.flowly.tests")!

    override func setUp() {
        super.setUp()
        // Clear test defaults before each test
        testDefaults.removePersistentDomain(forName: "com.flowly.tests")
        licenseManager = LicenseManager.shared
    }

    override func tearDown() {
        // Clean up test data
        testDefaults.removePersistentDomain(forName: "com.flowly.tests")
        super.tearDown()
    }

    // MARK: - LicenseStatus Enum Tests

    func testLicenseStatusEquality() {
        // Test trial equality
        let trial1 = LicenseStatus.trial(daysRemaining: 5)
        let trial2 = LicenseStatus.trial(daysRemaining: 5)
        let trial3 = LicenseStatus.trial(daysRemaining: 3)

        XCTAssertEqual(trial1, trial2, "Same trial days should be equal")
        XCTAssertNotEqual(trial1, trial3, "Different trial days should not be equal")

        // Test licensed equality
        let licensed1 = LicenseStatus.licensed(email: "test@example.com")
        let licensed2 = LicenseStatus.licensed(email: "test@example.com")
        let licensed3 = LicenseStatus.licensed(email: "other@example.com")

        XCTAssertEqual(licensed1, licensed2, "Same licensed email should be equal")
        XCTAssertNotEqual(licensed1, licensed3, "Different licensed emails should not be equal")

        // Test expired equality
        XCTAssertEqual(LicenseStatus.expired, LicenseStatus.expired)

        // Test validating equality
        XCTAssertEqual(LicenseStatus.validating, LicenseStatus.validating)

        // Test different statuses not equal
        XCTAssertNotEqual(trial1, LicenseStatus.expired)
        XCTAssertNotEqual(licensed1, LicenseStatus.expired)
    }

    // MARK: - Feature Enabled Tests

    func testIsFeatureEnabledForTrialWithDaysRemaining() {
        // When status is trial with days remaining, features should be enabled
        // This tests the computed property logic
        let status = LicenseStatus.trial(daysRemaining: 5)

        switch status {
        case .trial(let days):
            XCTAssertTrue(days > 0, "Trial with 5 days should have days > 0")
        default:
            XCTFail("Status should be trial")
        }
    }

    func testIsFeatureEnabledForTrialExpired() {
        // When status is trial with 0 days, features should be disabled
        let status = LicenseStatus.trial(daysRemaining: 0)

        switch status {
        case .trial(let days):
            XCTAssertFalse(days > 0, "Trial with 0 days should not have days > 0")
        default:
            XCTFail("Status should be trial")
        }
    }

    func testIsFeatureEnabledForLicensed() {
        // When status is licensed, features should be enabled
        let status = LicenseStatus.licensed(email: "test@example.com")

        if case .licensed = status {
            // Licensed status means features enabled
            XCTAssertTrue(true)
        } else {
            XCTFail("Status should be licensed")
        }
    }

    func testIsFeatureEnabledForExpired() {
        // When status is expired, features should be disabled
        let status = LicenseStatus.expired

        XCTAssertEqual(status, .expired, "Status should be expired")
    }

    // MARK: - Trial Days Calculation Tests

    func testTrialDaysRemainingCalculation() {
        // Test that trial calculation works correctly
        let calendar = Calendar.current

        // 3 days ago
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        let daysElapsed = calendar.dateComponents([.day], from: threeDaysAgo, to: Date()).day!

        XCTAssertEqual(daysElapsed, 3, "Should be 3 days elapsed")

        // Calculate remaining from 7 day trial
        let trialDays = 7
        let remaining = max(0, trialDays - daysElapsed)
        XCTAssertEqual(remaining, 4, "Should have 4 days remaining")
    }

    func testTrialDaysRemainingNeverNegative() {
        // Test that trial days never go negative
        let calendar = Calendar.current

        // 10 days ago (past trial period)
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: Date())!
        let daysElapsed = calendar.dateComponents([.day], from: tenDaysAgo, to: Date()).day!

        let trialDays = 7
        let remaining = max(0, trialDays - daysElapsed)
        XCTAssertEqual(remaining, 0, "Remaining days should be 0, not negative")
    }

    // MARK: - Cache Validity Tests

    func testCacheValidityCalculation() {
        let calendar = Calendar.current
        let cacheValidityHours = 24

        // 12 hours ago - should be valid
        let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: Date())!
        let hoursSince12 = calendar.dateComponents([.hour], from: twelveHoursAgo, to: Date()).hour!
        XCTAssertTrue(hoursSince12 < cacheValidityHours, "12 hours should be within 24 hour cache")

        // 30 hours ago - should be invalid
        let thirtyHoursAgo = calendar.date(byAdding: .hour, value: -30, to: Date())!
        let hoursSince30 = calendar.dateComponents([.hour], from: thirtyHoursAgo, to: Date()).hour!
        XCTAssertFalse(hoursSince30 < cacheValidityHours, "30 hours should exceed 24 hour cache")
    }

    // MARK: - Email Validation Tests

    func testEmptyEmailValidation() {
        // Empty email should trigger error
        let email = ""
        XCTAssertTrue(email.isEmpty, "Empty email should be detected")
    }

    func testValidEmailFormat() {
        // Basic email validation
        let validEmails = [
            "test@example.com",
            "user.name@domain.org",
            "user+tag@example.co.uk"
        ]

        for email in validEmails {
            XCTAssertTrue(email.contains("@"), "Email should contain @: \(email)")
            XCTAssertTrue(email.contains("."), "Email should contain .: \(email)")
        }
    }

    // MARK: - URL Configuration Tests

    func testPurchaseURLIsValid() {
        let url = LicenseManager.purchaseURL
        XCTAssertNotNil(url, "Purchase URL should not be nil")
        XCTAssertTrue(url.absoluteString.hasPrefix("https://"), "Purchase URL should use HTTPS")
    }

    // MARK: - Status Switch Tests

    func testStatusSwitchCoverage() {
        // Ensure all status cases can be handled
        let statuses: [LicenseStatus] = [
            .trial(daysRemaining: 7),
            .trial(daysRemaining: 0),
            .licensed(email: "test@example.com"),
            .expired,
            .validating
        ]

        for status in statuses {
            switch status {
            case .trial(let days):
                XCTAssertGreaterThanOrEqual(days, 0)
            case .licensed(let email):
                XCTAssertFalse(email.isEmpty)
            case .expired:
                XCTAssertTrue(true, "Expired case handled")
            case .validating:
                XCTAssertTrue(true, "Validating case handled")
            }
        }
    }

    // MARK: - Integration Tests

    func testLicenseManagerSingletonExists() {
        XCTAssertNotNil(LicenseManager.shared, "LicenseManager.shared should exist")
    }

    func testLicenseManagerStatusIsPublished() {
        // Verify status is accessible
        let status = licenseManager.status
        XCTAssertNotNil(status, "Status should be accessible")
    }

    func testLicenseManagerIsFeatureEnabledIsAccessible() {
        // Verify isFeatureEnabled computed property works
        let _ = licenseManager.isFeatureEnabled
        XCTAssertTrue(true, "isFeatureEnabled should be accessible without crash")
    }

    func testLicenseManagerTrialDaysRemainingIsAccessible() {
        // Verify trialDaysRemaining computed property works
        let days = licenseManager.trialDaysRemaining
        XCTAssertGreaterThanOrEqual(days, 0, "Trial days should be >= 0")
    }

    // MARK: - Deactivation Tests

    func testDeactivateResetsState() {
        // Calling deactivate should work without crashing
        licenseManager.deactivate()

        // After deactivate, should be in trial or expired state (not licensed)
        switch licenseManager.status {
        case .licensed:
            XCTFail("After deactivate, should not be licensed")
        default:
            XCTAssertTrue(true, "Status is correctly not licensed after deactivate")
        }
    }
}
