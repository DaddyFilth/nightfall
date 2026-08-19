#!/bin/bash
set -e

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=$HOME/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin
export GODOT_SILENCE_ROOT_WARNING=1

PROJECT_DIR=$HOME/nightfall
OUTPUT=$PROJECT_DIR/build/nightfall.apk

echo "🔨 Building Nightfall APK..."

cd $PROJECT_DIR
mkdir -p build

git pull origin main

godot --headless --editor --quit || true
godot --headless --export-release "Android" $OUTPUT

echo "✅ APK ready: $OUTPUT"
ls -lh $OUTPUT

sed -i '/^build//d' .gitignore
sed -i '/*.apk/d' .gitignore

git add build/nightfall.apk .gitignore
git commit -m "build: $(date '+%Y-%m-%d %H:%M')" || echo "Nothing new to commit"
git push

echo "🚀 Pushed to GitHub"
