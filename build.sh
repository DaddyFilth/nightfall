#!/bin/bash
set -e

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=$HOME/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin
export GODOT_SILENCE_ROOT_WARNING=1

PROJECT_DIR=$HOME/nightfall
OUTPUT=$PROJECT_DIR/build/nightfall.apk

cd $PROJECT_DIR
mkdir -p build

# Auto-increment version code
CURRENT=$(grep "version/code=" export_presets.cfg | head -1 | cut -d= -f2)
NEW=$((CURRENT + 1))
sed -i "s/version/code=$CURRENT/version/code=$NEW/" export_presets.cfg
echo "📦 Version: $NEW"

git pull origin main

godot --headless --editor --quit || true
godot --headless --export-release "Android" $OUTPUT

echo "✅ APK ready: $OUTPUT"
ls -lh $OUTPUT

sed -i '/^build//d' .gitignore
sed -i '/*.apk/d' .gitignore

git add build/nightfall.apk .gitignore export_presets.cfg
git commit -m "build: v$NEW $(date '+%Y-%m-%d %H:%M')"
git push

echo "🚀 Pushed to GitHub — v$NEW"
