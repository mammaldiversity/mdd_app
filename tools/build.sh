#!/bin/bash
set -e

echo "========================================="
echo "   MDD App Database & Build Script"
echo "========================================="

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# 1. Compile and run Rust CLI for DB generation
echo "--> Generating Database..."
./tools/generate_prefilled_db.sh

# 2. Build Flutter Apps
echo "--> Running flutter pub get..."
flutter pub get

echo "--> Running flutter analyze..."
flutter analyze

echo "--> Building Android (APK)..."
flutter build apk --release --split-per-abi

echo "--> Building iOS..."
# Using --no-codesign for pre-creation to avoid signing errors locally unless certificates are set up
flutter build ios --release --no-codesign || echo "iOS build encountered an error (likely expected if signing isn't configured, but workspace is prepared)."

echo "--> Building macOS..."
flutter build macos --release || echo "macOS build encountered an error (likely expected if signing isn't configured, but workspace is prepared)."

echo "--> Building Linux..."
# Linux build depends on having the correct dependencies installed (clang, cmake, pkg-config, libgtk-3-dev, etc.)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    flutter build linux --release
else
    echo "Skipping Linux build (not on a Linux host)."
fi

echo "--> Building Windows..."
if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32"* ]]; then
    flutter build windows --release
else
    echo "Skipping Windows build (not on a Windows host)."
fi

echo "========================================="
echo "   Build process complete."
echo "========================================="
