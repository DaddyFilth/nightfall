#!/usr/bin/env bash
set -euo pipefail

: "${GODOT_HEADERS_DIR:?Set GODOT_HEADERS_DIR to the matching Godot source root.}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$ROOT/NightfallIOSPreferenceBridge.xcodeproj"
SCHEME="NightfallIOSPreferenceBridge"
BUILD_ROOT="$ROOT/build"
EXPORT_ROOT="$ROOT/exports"

build_variant() {
  local configuration="$1"
  local variant="$2"
  local device_dir="$BUILD_ROOT/$variant/iphoneos"
  local simulator_dir="$BUILD_ROOT/$variant/iphonesimulator"
  local framework="$EXPORT_ROOT/NightfallIOSPreferenceBridge.$variant.xcframework"
  rm -rf "$device_dir" "$simulator_dir" "$framework"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$configuration" -sdk iphoneos GODOT_HEADERS_DIR="$GODOT_HEADERS_DIR" CONFIGURATION_BUILD_DIR="$device_dir" build
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$configuration" -sdk iphonesimulator ARCHS=arm64 ONLY_ACTIVE_ARCH=NO GODOT_HEADERS_DIR="$GODOT_HEADERS_DIR" CONFIGURATION_BUILD_DIR="$simulator_dir" build
  xcodebuild -create-xcframework -library "$device_dir/libNightfallIOSPreferenceBridge.a" -headers "$ROOT/Sources" -library "$simulator_dir/libNightfallIOSPreferenceBridge.a" -headers "$ROOT/Sources" -output "$framework"
}

build_variant Debug debug
build_variant Release release
