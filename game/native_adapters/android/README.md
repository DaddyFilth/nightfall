# NIGHTFALL Android Preference Bridge

This directory is a **Godot 4.7.2 Android plugin v2 Gradle project**. It packages the `NightfallAndroidPreferenceBridge` singleton required by `res://scripts/integration/native_preference_adapter.gd`. The singleton exposes one read-only GDScript method, `read_approved_payload()`, which returns UTF-8 JSON only from the signed host's internal `filesDir/nightfall-bridge/expo-preferences.v1.json` handoff path. It rejects missing, empty, oversized, unreadable, or path-escaped files.

The project cannot be compiled in this Linux sandbox because the Android SDK, Gradle runtime, and Android build tools are unavailable. No `.aar` has been fabricated or represented as compiled here.

| Requirement | Expected value |
|---|---|
| Host workstation | Android Studio with a JDK 17-compatible Gradle environment |
| Android SDK | API 35 compile SDK and an installed build-tools revision |
| Minimum Android version | API 24 |
| Godot dependency | `org.godotengine:godot:4.7.2.stable` from Maven Central |
| Output task | `:plugin:assembleGodotAddon` |

## Build and install

Open `game/native_adapters/android` in Android Studio, allow dependency synchronization, and run the Gradle task below from a workstation with the Android toolchain installed.

```bash
gradle :plugin:assembleGodotAddon
cp -R build/godot_addon/NightfallAndroidPreferenceBridge ../../addons/NightfallAndroidPreferenceBridge
```

Then open the Godot project, enable **Nightfall Android Preference Bridge** under **Project Settings → Plugins**, install the Android build template, and set the Android export preset's **Gradle Build → Use Gradle Build** option to `true`. The signed Expo host is responsible for validating and atomically copying the payload into its own internal storage before the Godot activity requests it.

> This plugin does not validate the JSON schema itself. The existing GDScript bridge remains the schema-validation and atomic-install authority, so the native layer has no broader privileges than a capped internal-file read.

## Device validation

Build a debug export first, confirm `Engine.has_singleton("NightfallAndroidPreferenceBridge")`, verify a valid host-copied payload installs, and confirm malformed or oversized payloads resolve fail-closed. Repeat against a signed release export before distribution.

## References

[1] [Godot Engine — Android plugins](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html)

[2] [Android Developers — Android library modules](https://developer.android.com/studio/projects/android-library)
