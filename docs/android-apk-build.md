# Android APK Build Readiness

Blood & Brass uses Expo SDK 54 with a managed Android configuration. The project is prepared for a **landscape-only native build** and includes the required asset, font, web-browser, audio, and screen-orientation plugins in `app.config.ts`.

## Release metadata

The next managed release is **version 1.0.1** with Android `versionCode: 2` and iOS `buildNumber: 2`. The Android package identifier remains stable at `com.app.nightfallbloodhunt`; do not change it after distribution begins, because Android uses it to identify updates for the installed application.

## Verified local checks

Run the following commands from the project root before starting an Android build:

```bash
pnpm install --frozen-lockfile
npx expo install --check
npx expo config --type public
pnpm check
pnpm test -- --maxWorkers=1 --minWorkers=1
```

The resolved configuration should report `orientation: "landscape"`, an Android package identifier, and these plugins: `expo-asset`, `expo-font`, `expo-web-browser`, and `expo-screen-orientation`.

## Generate the APK

Use the project’s **Publish** control after a checkpoint has been created. The managed native build process creates the APK; it should not be manually compiled in this sandbox because an Android SDK and Gradle toolchain are not available here.

## Managed signing boundary

Android signing material is intentionally **not stored in this repository**. The managed distribution service provisions or requests the release signing credentials through its secure build flow when Publish is selected. Do not add a keystore, keystore password, signing key alias, or signing password to `app.config.ts`, source control, or the app’s runtime environment.

For a distribution retry, create a checkpoint and select **Publish**. If the build service requests signing setup, complete it only in that secure interface. Preserve the first native failure block if the retry fails.

If an Android build fails again, retain the exact build-log section beginning with `FAILURE: Build failed with an exception.` and use it with the compatibility commands above. The log identifies whether the failure is a dependency, config-plugin, signing, or remote-build issue.
