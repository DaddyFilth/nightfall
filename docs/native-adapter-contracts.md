# Native Preference Adapter Contracts

The in-project runtime exposes `NativePreferenceAdapter.install_from_native_adapter()`. It looks only for a named Godot singleton, asks it for `read_approved_payload()`, parses the returned JSON, and passes the result through the same schema validator and atomic user-sandbox installer used by the local bridge.

| Platform | Required singleton | Native artifact contract | Adapter responsibility |
|---|---|---|---|
| Android | `NightfallAndroidPreferenceBridge` | A Godot Android Plugin v2 Gradle project in `game/native_adapters/android`. | Read a capped payload from an approved host-copied app-owned directory and return UTF-8 JSON. |
| iOS | `NightfallIOSPreferenceBridge` | An Xcode static-library project and `.gdip` descriptor in `game/native_adapters/ios/NightfallIOSPreferenceBridgePlugin`. | Read a capped payload from an approved host-owned app-group/container handoff and return UTF-8 JSON. |

The GDScript adapter does not guess file paths outside its own `user://` sandbox, does not grant another app access to private data, and rejects missing plugins or malformed payloads. The repository now contains build-ready native projects, but this sandbox does **not** contain Android SDK or Xcode toolchains; therefore no `.aar`, static library, or `.xcframework` has been compiled here. A production release still requires platform-specific compilation, export configuration, Apple/Android signing, host-side copy logic, and physical-device verification.[1] [2]

## References

[1] [Godot Engine — Android plugins](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html)

[2] [Godot Engine — Creating iOS plugins](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)
