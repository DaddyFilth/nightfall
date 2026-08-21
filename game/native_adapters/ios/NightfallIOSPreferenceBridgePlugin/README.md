# NIGHTFALL iOS Preference Bridge

This is an Xcode static-library project for the `NightfallIOSPreferenceBridge` Godot singleton. It is designed for a signed iOS host that deliberately copies an already-validated Expo handoff payload into a configured application-group container. The native bridge provides only `read_approved_payload()`; it validates the app-group identifier and relative path, caps reads at 16 KiB, requires UTF-8, and returns an empty string for every failure.

The sandbox cannot compile this library: iOS builds require macOS, Xcode, Apple SDKs, signing material, and Godot headers matched to the iOS export template. The repository contains **source, project configuration, descriptor, and build script only**; no static library or `.xcframework` is claimed as built.

| Requirement | Expected value |
|---|---|
| Host workstation | macOS with Xcode 16 or later |
| Deployment target | iOS 14.0 |
| Godot headers | Godot 4.7.2 source headers matching the export template |
| Static-library target | `NightfallIOSPreferenceBridge` |
| Output artifacts | Debug and release `.xcframework` packages plus `.gdip` descriptor |

## Build and install

On a macOS workstation, set `GODOT_HEADERS_DIR` to the matching Godot source root and run:

```bash
cd game/native_adapters/ios/NightfallIOSPreferenceBridgePlugin
chmod +x build_xcframework.sh
GODOT_HEADERS_DIR=/absolute/path/to/godot-4.7.2 ./build_xcframework.sh
```

Copy the descriptor and both generated `.xcframework` packages into `res://ios/plugins/NightfallIOSPreferenceBridge`, then enable the plugin in the iOS export preset. In the signed host's iOS target, set the export field `NightfallPreferenceBridgeAppGroup` to the entitled app-group identifier and provision that entitlement in both host and Godot targets. Do not enable the bridge until physical-device verification proves the app-group payload flow.

> The `.gdip` is configured through an export-time string input, rather than embedding a production app-group identifier in source control. The GDScript layer remains the schema-validation and atomic-install authority.

## References

[1] [Godot Engine — Creating iOS plugins](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)

[2] [Godot iOS plugins reference project](https://github.com/godot-sdk-integrations/godot-ios-plugins)
