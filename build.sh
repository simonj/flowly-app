#!/bin/bash

# Build and run Flowly app

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "Building Flowly..."
xcodebuild -project Flowly.xcodeproj \
           -scheme Flowly \
           -configuration Release \
           clean build \
           > /dev/null 2>&1

if [ $? -eq 0 ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Flowly-*/Build/Products/Release/Flowly.app -maxdepth 0 2>/dev/null | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "✓ Build successful!"
        echo ""
        echo "App location: $APP_PATH"
        echo ""
        echo "To install: Drag the app to /Applications"
        echo "To run now: open \"$APP_PATH\""
        echo ""
        read -p "Open the app now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$APP_PATH"
        fi
    else
        echo "✗ Build succeeded but app not found"
    fi
else
    echo "✗ Build failed"
    exit 1
fi


