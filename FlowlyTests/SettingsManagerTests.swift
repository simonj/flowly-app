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

        // Defaults use the Balanced preset
        XCTAssertEqual(settings.stepSize, 90.0, "Default stepSize should be 90 (Balanced)")
        XCTAssertEqual(settings.animationTime, 300.0, "Default animationTime should be 300 (Balanced)")
        XCTAssertEqual(settings.accelerationDelta, 70.0, "Default accelerationDelta should be 70 (Balanced)")
        XCTAssertEqual(settings.accelerationScale, 5.0, "Default accelerationScale should be 5 (Balanced)")
        XCTAssertEqual(settings.pulseScale, 3.0, "Default pulseScale should be 3 (Balanced)")
        XCTAssertTrue(settings.animationEasingEnabled, "Default animationEasingEnabled should be true")
        XCTAssertTrue(settings.standardWheelDirection, "Default standardWheelDirection should be true")
        XCTAssertTrue(settings.horizontalScrollingEnabled, "Default horizontalScrollingEnabled should be true")
        XCTAssertEqual(settings.selectedPreset, .balanced, "Default preset should be Balanced")
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

        // Verify all defaults restored (Balanced preset values)
        XCTAssertEqual(settings.stepSize, 90.0)
        XCTAssertEqual(settings.animationTime, 300.0)
        XCTAssertEqual(settings.accelerationDelta, 70.0)
        XCTAssertEqual(settings.accelerationScale, 5.0)
        XCTAssertEqual(settings.pulseScale, 3.0)
        XCTAssertTrue(settings.animationEasingEnabled)
        XCTAssertTrue(settings.standardWheelDirection)
        XCTAssertTrue(settings.horizontalScrollingEnabled)
        XCTAssertEqual(settings.selectedPreset, .balanced)
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
