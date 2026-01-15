# Xcode Project Setup Guide

This guide will help you create an Xcode project for SmoothScroll.

## Quick Setup (Xcode)

1. **Open Xcode** and create a new project:
   - File → New → Project
   - Select **macOS** → **App**
   - Click **Next**

2. **Configure the project**:
   - Product Name: `SmoothScroll`
   - Team: Your development team (or personal team)
   - Organization Identifier: `com.yourname` (or your domain)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Click **Next** and choose where to save

3. **Add existing files**:
   - Right-click on the project navigator
   - Select **Add Files to "SmoothScroll"...**
   - Add all the `.swift` files from:
     - `SmoothScrollApp.swift` (root)
     - `Services/` folder
     - `Views/` folder
   - Make sure **"Copy items if needed"** is UNCHECKED (files are already in place)
   - Make sure **"Create groups"** is selected
   - Click **Add**

4. **Configure Info.plist**:
   - Replace the default `Info.plist` content with the provided `Info.plist`
   - Or manually add these keys in Xcode:
     - `LSUIElement`: `YES` (menu bar app, no dock icon)
     - `NSSupportsAutomaticTermination`: `YES`
     - `NSSupportsSuddenTermination`: `YES`

5. **Add Accessibility Entitlement**:
   - Select your project in the navigator
   - Select the **SmoothScroll** target
   - Go to **Signing & Capabilities** tab
   - Click **+ Capability**
   - Add **App Sandbox** (if not already added)
   - Under App Sandbox, set **Input Monitoring** to allowed
   - Note: You may also need to add this to entitlements file manually

6. **Set Deployment Target**:
   - In **Build Settings** → **macOS Deployment Target**
   - Set to **13.0** or later (required for MenuBarExtra)

7. **Build and Run**:
   - Press **Cmd + R** to build and run
   - The app should appear in your menu bar

## Alternative: Command Line Setup

If you prefer using Xcode's command line tools:

```bash
# Create a new Xcode project (interactive)
# This requires Xcode to be installed
open -a Xcode
# Then follow the GUI steps above
```

## Project Structure

After setup, your Xcode project should look like:

```
SmoothScroll.xcodeproj
SmoothScroll/
├── SmoothScrollApp.swift
├── Services/
│   ├── ScrollEventTap.swift
│   ├── ScrollSmoother.swift
│   └── SettingsManager.swift
├── Views/
│   ├── MenuBarView.swift
│   └── SettingsView.swift
├── Info.plist
└── README.md
```

## Notes

- The app requires **Accessibility permissions** to work
- First launch will prompt for permission (or guide you to System Settings)
- The app runs as a menu bar utility (no dock icon) due to `LSUIElement` setting

