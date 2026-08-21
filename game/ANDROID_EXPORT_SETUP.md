# Blood & Brass — Android Export Setup

This Godot handoff intentionally does **not** include an Android SDK, Java installation, export templates, or a release keystore. Those are machine-specific tools and credentials that must be installed and configured on the computer or Android device that performs the export.

> The reported failure is a local export-toolchain setup problem, not a missing gameplay file. The project itself imports and passes its native regression suite in Godot 4.7.2.

## Resolve the current errors

| Reported message | Required correction |
|---|---|
| `No export template found ... 4.7.2.stable/android_source.zip` | In the same **Godot 4.7.2** editor used to open the project, choose **Editor > Manage Export Templates**, then download/install the templates for the current version. The editor and templates must match. |
| `Android build template not installed in the project` | After the export templates are installed, choose **Project > Install Android Build Template** and approve the install. Godot creates `android/build/` beneath the project. |
| Java SDK missing `bin` | Install **OpenJDK 17** and set **Editor Settings > Export > Android > Java SDK Path** to the JDK directory that contains `bin/java`. |
| Android SDK missing `platform-tools`, `build-tools`, or `adb` | Set **Editor Settings > Export > Android > Android SDK Path** to the SDK root. It must contain `platform-tools/adb`, `build-tools/<version>/apksigner`, and the Android platform packages. |
| Release keystore incorrectly configured | For a local test APK, keep **Export With Debug** selected and use the debug configuration. For a release, create a keystore, then enter the exact file path, alias, and matching password in the Android export preset. |

Godot’s current Android-export guide recommends OpenJDK 17, Android SDK Platform-Tools 35.0.0+, Build-Tools 35.0.1, Android Platform 35, and the latest command-line tools. It documents these required packages and the two editor paths under Android export settings. [1]

## Recommended route for a direct device test

For the fastest no-store device test, create an **Android** export preset and choose an **APK**. Keep **Export With Debug** checked. APKs are directly installable on an Android device, whereas AAB is intended for store submission. [2]

1. Import the project and install Godot 4.7.2 export templates.
2. Install the Android build template in the project.
3. Install/configure OpenJDK 17 and the Android SDK packages listed above.
4. In **Project > Export**, add an Android preset and set a unique package identifier.
5. In that preset, open **Resources** and set **Export Mode** to **Export all resources in the project**. Do not use a filter that excludes `assets/`, `scenes/`, or `scripts/`; these contain the built-in dockyard artwork, visual/animation code, and campaign content.
6. Export an APK with debug enabled, transfer it to the test device, and allow that installer/file manager to install unknown apps for the one install.

For a release APK or AAB, generate a private keystore with the JDK’s `keytool`, store it outside the repository, and set its path, alias, and password in **Release** fields. Do not commit a keystore or its passwords. Godot documents the release-signing fields and cautions that the key verifies developer identity. [1]

```bash
keytool -v -genkey -keystore blood-and-brass-release.keystore \
  -alias bloodandbrass -keyalg RSA -validity 10000
```

## Preflight before opening the export dialog

The handoff includes a local preflight script that checks the exact files Godot reports as missing. It does not install software, alter Editor Settings, or handle credentials.

```bash
cd /path/to/Blood-and-Brass-Godot-Project
chmod +x tools/android_export_preflight.sh
./tools/android_export_preflight.sh \
  /path/to/openjdk-17 \
  /path/to/android-sdk \
  "$HOME/.local/share/godot"
```

For the Termux path shown in the error, the third argument is normally `/data/data/com.termux/files/home/.local/share/godot`. The script expects a matching `4.7.2.stable` template directory by default; override it only if the Godot editor’s actual template version differs:

```bash
GODOT_TEMPLATE_VERSION=4.7.2.stable ./tools/android_export_preflight.sh <java-sdk> <android-sdk> <godot-data>
```

## Termux and the Godot Android editor

The mobile Godot editor is an early-access workflow. Godot documents that it can create and export projects on Android, but its user experience is not optimized for phone form factors and has known limitations. [3] A Termux-only setup is not bundled with this project: it still needs a compatible Java runtime, Android SDK root, build tools, and matching Godot export templates at paths visible to the editor.

If the path shown in the error begins with `/data/data/com.termux/`, first verify that the Godot editor can read that location and that it contains the exact directories listed above. If it cannot, install/configure the requirements in a location accessible to the editor, or perform the export on a desktop Godot/Android Studio setup. This does not change the project source or its local save behavior.

## Why no export preset is included

`export_presets.cfg` is not included because it can contain computer-specific SDK paths and release-signing configuration. Create the preset locally so it references **your** SDK and **your** keystore. This is safer than distributing an invalid preset or exposing signing metadata.

## References

[1]: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html "Godot: Exporting for Android"
[2]: https://developer.android.com/games/engines/godot/godot-export "Android Developers: Export Godot projects to Android"
[3]: https://docs.godotengine.org/en/stable/tutorials/editor/using_the_android_editor.html "Godot: Using the Android editor"
