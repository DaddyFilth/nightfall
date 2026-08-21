#!/usr/bin/env sh
# Blood & Brass Android export preflight
# Usage: ./tools/android_export_preflight.sh <java-sdk-path> <android-sdk-path> [godot-data-path]
set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <java-sdk-path> <android-sdk-path> [godot-data-path]" >&2
  exit 64
fi

JAVA_SDK_PATH=$1
ANDROID_SDK_PATH=$2
GODOT_DATA_PATH=${3:-"$HOME/.local/share/godot"}
GODOT_TEMPLATE_VERSION=${GODOT_TEMPLATE_VERSION:-4.7.2.stable}
TEMPLATE_PATH="$GODOT_DATA_PATH/export_templates/$GODOT_TEMPLATE_VERSION"
missing=0

check_file() {
  if [ -f "$1" ]; then
    echo "PASS  $2"
  else
    echo "FAIL  $2: $1" >&2
    missing=1
  fi
}

check_directory() {
  if [ -d "$1" ]; then
    echo "PASS  $2"
  else
    echo "FAIL  $2: $1" >&2
    missing=1
  fi
}

echo "Blood & Brass Android export preflight"
echo "Godot template version: $GODOT_TEMPLATE_VERSION"

check_file "$JAVA_SDK_PATH/bin/java" "OpenJDK runtime"
check_file "$JAVA_SDK_PATH/bin/keytool" "release-key utility"
check_file "$ANDROID_SDK_PATH/platform-tools/adb" "Android Platform-Tools adb"
check_directory "$ANDROID_SDK_PATH/build-tools" "Android Build-Tools directory"
check_directory "$ANDROID_SDK_PATH/platforms" "Android platform directory"
check_directory "$ANDROID_SDK_PATH/cmdline-tools" "Android command-line tools directory"

if find "$ANDROID_SDK_PATH/build-tools" -mindepth 2 -maxdepth 2 -name apksigner -type f 2>/dev/null | grep -q .; then
  echo "PASS  Android Build-Tools apksigner"
else
  echo "FAIL  Android Build-Tools apksigner: install a Build-Tools package" >&2
  missing=1
fi

check_file "$TEMPLATE_PATH/android_source.zip" "matching Godot Android source template"

if [ "$missing" -ne 0 ]; then
  echo "\nPreflight failed. Install the missing components, then set the same Java/Android SDK paths in Godot Editor Settings > Export > Android." >&2
  exit 1
fi

echo "\nPreflight passed. In Godot, install the Android build template in the project, create an Android preset, and export a debug APK before configuring a release keystore."
