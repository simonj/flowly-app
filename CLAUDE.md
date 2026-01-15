# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build from command line
xcodebuild -project SmoothScroll.xcodeproj -scheme SmoothScroll -configuration Release clean build

# Build and run (interactive script)
./build.sh

# Open in Xcode
open SmoothScroll.xcodeproj
```

The built app is located at `~/Library/Developer/Xcode/DerivedData/SmoothScroll-*/Build/Products/Release/SmoothScroll.app`

## Architecture

SmoothScroll is a macOS menu bar utility that intercepts scroll wheel events and applies smooth animation. It requires macOS 13.0+ and Accessibility permissions.

### Core Components

**Event Interception Layer** (`Services/ScrollEventTap.swift`)
- Uses `CGEventTap` to intercept scroll wheel events at the system level
- Checks `AXIsProcessTrusted()` for accessibility permissions before starting
- Passes scroll deltas to ScrollSmoother, returns `nil` to suppress original events

**Scroll Animation Engine** (`Services/ScrollSmoother.swift`)
- Converts single scroll events into animated sequences (~60fps)
- Uses ease-out curve: `1 - (1 - t)^2` for natural deceleration
- Posts synthetic scroll events via `CGEvent.post(tap: .cghidEventTap)`
- Cancels in-flight animations when new scroll input arrives

**Settings** (`Services/SettingsManager.swift`)
- Singleton pattern with `@Published` properties for SwiftUI binding
- Persists animation duration (50-500ms, default 200ms) via UserDefaults

### SwiftUI Integration

`ScrollEventTapObservable` (in `Views/SettingsView.swift`) wraps `ScrollEventTap` for SwiftUI's `@ObservedObject`. The app uses `MenuBarExtra` with `.window` style for the menu bar interface.

### Key Info.plist Settings

- `LSUIElement: YES` - Runs as menu bar app without dock icon
- Requires Accessibility permission (Input Monitoring capability in App Sandbox)
