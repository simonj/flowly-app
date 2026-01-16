# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build from command line
xcodebuild -project Flowly.xcodeproj -scheme Flowly -configuration Release clean build

# Build and run (interactive script)
./build.sh

# Open in Xcode
open Flowly.xcodeproj
```

The built app is located at `~/Library/Developer/Xcode/DerivedData/Flowly-*/Build/Products/Release/Flowly.app`

## Architecture

Flowly is a macOS menu bar utility that intercepts scroll wheel events and applies smooth animation. It requires macOS 13.0+ and Accessibility permissions.

### Core Components

**Event Interception Layer** (`Flowly/Services/ScrollEventTap.swift`)
- Uses `CGEventTap` to intercept scroll wheel events at the system level
- Checks `AXIsProcessTrusted()` for accessibility permissions before starting
- Applies wheel direction inversion based on settings
- Passes scroll deltas to ScrollSmoother, returns `nil` to suppress original events

**Scroll Animation Engine** (`Flowly/Services/ScrollSmoother.swift`)
- Converts single scroll events into animated sequences (~60fps using DispatchSourceTimer)
- Accumulates scroll deltas into running animations (no cancellation jerk)
- Tracks fractional pixel remainder to avoid truncation loss
- Implements acceleration detection (time between scroll events)
- Configurable ease-out curve with pulse scale modifier: `1 - (1 - t)^exponent`
- Posts synthetic scroll events via `CGEvent.post(tap: .cghidEventTap)`

**Settings** (`Flowly/Services/SettingsManager.swift`)
- Singleton pattern with `@Published` properties for SwiftUI binding
- Persists all settings via UserDefaults with bounds validation
- Settings: stepSize, animationTime, accelerationDelta, accelerationScale, pulseScale
- Toggles: autoStartOnLogin, animationEasingEnabled, standardWheelDirection, horizontalScrollingEnabled
- Uses `SMAppService` for Launch at Login functionality

### SwiftUI Integration

`ScrollEventTapObservable` (in `Views/SettingsView.swift`) wraps `ScrollEventTap` for SwiftUI's `@ObservedObject`. The app uses `MenuBarExtra` with `.window` style for the menu bar interface.

### Key Info.plist Settings

- `LSUIElement: YES` - Runs as menu bar app without dock icon
- Requires Accessibility permission (Input Monitoring capability in App Sandbox)
