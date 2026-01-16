//
//  SettingsManagerTests.swift
//  FlowlyTests
//
//  Unit tests for SettingsManager
//

import XCTest
@testable import Flowly

final class SettingsManagerTests: XCTestCase {

    var settings: SettingsManager!

    override func setUp() {
        super.setUp()
        settings = SettingsManager.shared
        // Reset to known state before each test
        settings.resetToDefaults()
    }

    // MARK: - Default Values Tests

    func testDefaultValues() {
        settings.resetToDefaults()

        XCTAssertEqual(settings.stepSize, 90.0, "Default stepSize should be 90")
        XCTAssertEqual(settings.animationTime, 360.0, "Default animationTime should be 360")
        XCTAssertEqual(settings.accelerationDelta, 70.0, "Default accelerationDelta should be 70")
        XCTAssertEqual(settings.accelerationScale, 7.0, "Default accelerationScale should be 7")
        XCTAssertEqual(settings.pulseScale, 4.0, "Default pulseScale should be 4")
        XCTAssertTrue(settings.animationEasingEnabled, "Default animationEasingEnabled should be true")
        XCTAssertTrue(settings.standardWheelDirection, "Default standardWheelDirection should be true")
        XCTAssertTrue(settings.horizontalScrollingEnabled, "Default horizontalScrollingEnabled should be true")
    }

    // MARK: - Bounds Clamping Tests

    func testStepSizeClampsToValidRange() {
        // Test lower bound
        settings.stepSize = 5.0
        XCTAssertEqual(settings.stepSize, 10.0, "stepSize should clamp to minimum 10")

        // Test upper bound
        settings.stepSize = 500.0
        XCTAssertEqual(settings.stepSize, 300.0, "stepSize should clamp to maximum 300")

        // Test valid value
        settings.stepSize = 150.0
        XCTAssertEqual(settings.stepSize, 150.0, "stepSize should accept valid value 150")
    }

    func testAnimationTimeClampsToValidRange() {
        // Test lower bound
        settings.animationTime = 10.0
        XCTAssertEqual(settings.animationTime, 50.0, "animationTime should clamp to minimum 50")

        // Test upper bound
        settings.animationTime = 2000.0
        XCTAssertEqual(settings.animationTime, 1000.0, "animationTime should clamp to maximum 1000")

        // Test valid value
        settings.animationTime = 500.0
        XCTAssertEqual(settings.animationTime, 500.0, "animationTime should accept valid value 500")
    }

    // MARK: - Reset Tests

    func testResetToDefaults() {
        // Change all values
        settings.stepSize = 200.0
        settings.animationTime = 800.0
        settings.accelerationDelta = 150.0
        settings.accelerationScale = 15.0
        settings.pulseScale = 8.0
        settings.animationEasingEnabled = false
        settings.standardWheelDirection = false
        settings.horizontalScrollingEnabled = false

        // Reset
        settings.resetToDefaults()

        // Verify all defaults restored
        XCTAssertEqual(settings.stepSize, 90.0)
        XCTAssertEqual(settings.animationTime, 360.0)
        XCTAssertEqual(settings.accelerationDelta, 70.0)
        XCTAssertEqual(settings.accelerationScale, 7.0)
        XCTAssertEqual(settings.pulseScale, 4.0)
        XCTAssertTrue(settings.animationEasingEnabled)
        XCTAssertTrue(settings.standardWheelDirection)
        XCTAssertTrue(settings.horizontalScrollingEnabled)
    }

    // MARK: - Boolean Toggle Tests

    func testBooleanToggles() {
        settings.animationEasingEnabled = false
        XCTAssertFalse(settings.animationEasingEnabled)

        settings.animationEasingEnabled = true
        XCTAssertTrue(settings.animationEasingEnabled)

        settings.horizontalScrollingEnabled = false
        XCTAssertFalse(settings.horizontalScrollingEnabled)

        settings.standardWheelDirection = false
        XCTAssertFalse(settings.standardWheelDirection)
    }
}
