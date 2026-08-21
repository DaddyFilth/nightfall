# Native Adapter Research — Godot Mobile Bridge

The project’s local preference-file bridge can be wrapped by platform-native Godot plugins, but the current project does not include compiled plugin binaries or a signed mobile export.

| Platform | Official plugin route | Implication for this project |
|---|---|---|
| **Android** | Godot 4.2+ documents Android Plugin v2 as an Android library that depends on the Godot Android library, is packaged through the editor export-plugin flow, and exposes native methods through a `GodotPlugin` init class.[1] | The Android adapter contract should be implemented as a Kotlin/Java plugin that copies an approved host payload into the Godot user sandbox, then invokes the existing validated file bridge. |
| **iOS** | Godot documents iOS plugins as a `.gdip` configuration plus a static library or `.xcframework`; the configuration can declare linked/embedded frameworks, copied files, and Info.plist data.[2] | The iOS adapter contract should be implemented as an Objective-C/Swift-compatible plugin package that places the approved payload into the Godot sandbox and invokes the same validated file bridge. |

Neither documentation path authorizes one application to read another application’s private sandbox directly. A shipping implementation still needs platform-native host ownership, plugin binaries, export configuration, signing, and physical-device verification. The repository intentionally provides only contracts and validated local logic at this stage.

## References

[1] [Godot Engine — Android plugins](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html)

[2] [Godot Engine — Creating iOS plugins](https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html)

