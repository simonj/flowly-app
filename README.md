# SmoothScroll macOS App

A macOS menu bar utility that enhances scroll wheel smoothness for Logitech (and other third-party) mice by intercepting scroll events and applying smooth animation.

## Features

- **Smooth Scrolling**: Transforms choppy scroll wheel events into smooth, animated scrolling
- **Configurable Animation Duration**: Adjust smoothing duration from 50ms to 500ms (default: 200ms)
- **Menu Bar Utility**: Runs in the background, accessible from the menu bar
- **Global Settings**: Applies to all applications system-wide

## Installation

### Building from Source

1. **Prerequisites**:
   - macOS 13.0 (Ventura) or later
   - Xcode 14.0 or later
   - Swift 5.7 or later

2. **Build Steps**:
   ```bash
   # Clone or navigate to the project directory
   cd smoothscroolClone
   
   # Open in Xcode
   open SmoothScroll.xcodeproj
   
   # Or build from command line:
   xcodebuild -scheme SmoothScroll -configuration Release
   ```

3. **Run the App**:
   - Build and run from Xcode, or
   - Run the built app from `Products/SmoothScroll.app`

## First Launch

### Accessibility Permission

When you first launch SmoothScroll, macOS will prompt you to grant accessibility permissions. This is **required** for the app to intercept scroll events.

1. **Automatic Prompt**: When you first run the app, macOS may automatically show a permission dialog
2. **Manual Permission**: If the dialog doesn't appear:
   - Open **System Settings** (or System Preferences on older macOS)
   - Go to **Privacy & Security** → **Accessibility**
   - Look for **SmoothScroll** in the list
   - Toggle it **ON**
   - If SmoothScroll isn't listed, click the **+** button and navigate to the app

3. **Verify Permission**: Check the menu bar icon - it should show:
   - **Green dot**: Active (permission granted)
   - **Red dot**: Permission Required (click Settings to open System Settings)

## Usage

### Menu Bar Access

1. Look for the **SmoothScroll** icon in your menu bar (double arrow icon)
2. Click the icon to open the menu
3. The menu shows:
   - **Status indicator**: Green (Active) or Red (Permission Required)
   - **Settings**: Opens the settings window
   - **Quit**: Exits the app

### Settings Window

Access settings by:
- Clicking **Settings** from the menu bar dropdown, or
- Using **Cmd + ,** (Command + Comma) when the settings window is in focus

#### Animation Duration

- **Range**: 50ms to 500ms
- **Default**: 200ms
- **How it works**:
  - **Lower values (50-150ms)**: Faster scrolling, less smooth
  - **Medium values (150-300ms)**: Balanced smoothness and speed (recommended)
  - **Higher values (300-500ms)**: Very smooth but slower scrolling

**Adjusting**:
1. Open Settings
2. Use the slider to adjust Animation Duration
3. The value updates in real-time - try scrolling to test
4. Changes are saved automatically

### Resetting Settings

Click **Reset to Defaults** in the Settings window to restore:
- Animation Duration: 200ms

## How It Works

SmoothScroll uses macOS's `CGEventTap` API to:

1. **Intercept** scroll wheel events before they reach applications
2. **Cancel** the original choppy scroll event
3. **Break down** the scroll delta into smaller increments
4. **Emit** smooth scroll events over a configurable duration using an ease-out animation curve
5. **Apply** the smooth scrolling globally across all applications

The smooth scrolling algorithm:
- Divides scroll events into approximately 60 steps per second
- Uses an ease-out curve for natural deceleration
- Maintains the total scroll distance while smoothing the motion

## Troubleshooting

### Smooth Scroll Not Working

**Check Permission Status**:
1. Open the menu bar dropdown
2. Check if status shows "Active" (green) or "Permission Required" (red)
3. If red, click Settings and follow the permission instructions

**Re-grant Permissions**:
1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Find **SmoothScroll** and toggle it OFF then ON
3. Restart SmoothScroll

**Verify Event Tap**:
- Check Console.app for any error messages
- Ensure no other apps are interfering with event taps

### Scrolling Feels Too Slow

- **Solution**: Decrease Animation Duration in Settings
- Try values between 50-150ms for faster scrolling

### Scrolling Still Feels Choppy

- **Solution**: Increase Animation Duration in Settings
- Try values between 250-400ms for smoother scrolling
- Note: Higher values make scrolling slower overall

### App Doesn't Appear in Menu Bar

- **Check**: Ensure the app is running (check Activity Monitor)
- **Restart**: Quit and relaunch the app
- **macOS Version**: Requires macOS 13.0+ for MenuBarExtra

### Permission Dialog Doesn't Appear

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Manually add SmoothScroll if it's not listed
3. Ensure the toggle is enabled

## Technical Details

- **Framework**: SwiftUI
- **APIs Used**:
  - `CGEventTap` for event interception
  - `CGEvent` for creating scroll events
  - `AXIsProcessTrusted` for permission checking
- **Platform**: macOS 13.0+
- **Architecture**: Menu bar utility (LSUIElement)

## License

This project is provided as-is for educational and personal use.

## Credits

Inspired by [SmoothScroll.net](https://www.smoothscroll.net/) and similar macOS smooth scrolling utilities like Mos and BetterMouse.

