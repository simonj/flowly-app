//
//  ScrollSmootherTests.swift
//  FlowlyTests
//
//  Unit tests for ScrollSmoother easing functions
//

import XCTest
@testable import Flowly

final class ScrollSmootherTests: XCTestCase {

    var smoother: ScrollSmoother!
    var settings: SettingsManager!

    override func setUp() {
        super.setUp()
        settings = SettingsManager.shared
        settings.resetToDefaults()
        smoother = ScrollSmoother(settingsManager: settings)
    }

    override func tearDown() {
        smoother.cancelAnimations()
        super.tearDown()
    }

    // MARK: - Ease Progress Tests

    func testEaseProgressAtZeroReturnsZero() {
        settings.animationEasingEnabled = true
        let result = smoother.easeProgress(0.0)
        XCTAssertEqual(result, 0.0, accuracy: 0.001, "easeProgress(0) should return 0")
    }

    func testEaseProgressAtOneReturnsOne() {
        settings.animationEasingEnabled = true
        let result = smoother.easeProgress(1.0)
        XCTAssertEqual(result, 1.0, accuracy: 0.001, "easeProgress(1) should return 1")
    }

    func testEaseProgressLinearWhenEasingDisabled() {
        settings.animationEasingEnabled = false

        // When easing is disabled, should return linear (t)
        XCTAssertEqual(smoother.easeProgress(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(smoother.easeProgress(0.25), 0.25, accuracy: 0.001)
        XCTAssertEqual(smoother.easeProgress(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(smoother.easeProgress(0.75), 0.75, accuracy: 0.001)
        XCTAssertEqual(smoother.easeProgress(1.0), 1.0, accuracy: 0.001)
    }

    func testEaseProgressWithEasingEnabled() {
        settings.animationEasingEnabled = true
        settings.pulseScale = 4.0

        // With easing enabled, midpoint should be > 0.5 (ease-out curve)
        let midpoint = smoother.easeProgress(0.5)
        XCTAssertGreaterThan(midpoint, 0.5, "Ease-out curve at t=0.5 should be > 0.5")
        XCTAssertLessThan(midpoint, 1.0, "Ease-out curve at t=0.5 should be < 1.0")
    }

    func testHigherPulseScaleGivesMoreAggressiveCurve() {
        settings.animationEasingEnabled = true

        // Test with low pulse scale
        settings.pulseScale = 1.0
        let lowPulseMidpoint = smoother.easeProgress(0.5)

        // Test with high pulse scale
        settings.pulseScale = 10.0
        let highPulseMidpoint = smoother.easeProgress(0.5)

        // Higher pulse scale should give more aggressive easing (higher value at midpoint)
        XCTAssertGreaterThan(highPulseMidpoint, lowPulseMidpoint,
            "Higher pulseScale should produce more aggressive easing curve")
    }
}
