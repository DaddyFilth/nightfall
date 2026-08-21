# Blood & Brass Security and Build Operations

**Scope.** This runbook records the current security baseline, reproducible verification commands, and supported distribution paths for the Blood & Brass mobile prototype. It applies to the Expo application, its Express/tRPC service, and the native Godot vertical slice.

## Release security status

The verified full dependency audit has been reduced from **2 critical, 70 high, 45 moderate, and 6 low** findings to **0 critical, 2 high, 0 moderate, and 0 low** findings. Both remaining high-severity advisories are in the same unpatched Metro build-time package, `image-size`; they are explicitly retained rather than hidden from the audit. `pnpm audit` is the appropriate command for checking the resolved package tree against known security advisories, and its `--prod` flag limits the check to production dependencies. [1]

| Area | Current state | Verification evidence |
|---|---|---|
| Direct dependency remediation | `@trpc/*` is pinned to 11.18.0, `axios` to 1.19.0 or newer, and `drizzle-orm` to 0.45.2 or newer. | Frozen lockfile installation and TypeScript compilation pass. |
| Transitive dependency remediation | The committed pnpm audit override block and `pnpm-lock.yaml` resolve `js-yaml` 4.3.1, `postcss` 8.5.23, `qs` 6.15.2 or newer, and `uuid` 11.1.1 or newer. | Production audit no longer reports those advisories. |
| Remaining advisories | `image-size` remains the source of two high-severity Metro/Expo build-time transitive advisories. Both report no patched version (`<0.0.0`). | The full and production audits return a nonzero result only for `image-size`. |
| Runtime exposure | `image-size` is used by Expo/Metro tooling while building or bundling; it is not shipped as an application runtime dependency. | Dependency path inspection resolves it under the Expo CLI/Metro toolchain. |

> **Do not suppress the remaining `image-size` finding.** It has no upstream patch to force safely. Keep the Expo SDK current within its supported compatibility range, review the audit on every dependency refresh, and remove this exception only when Expo publishes a compatible patched dependency.

The project is pinned to `pnpm@9.12.0`. The root `pnpm.overrides` block is retained because it produced the verified dependency graph recorded in `pnpm-lock.yaml`. A later package-manager upgrade should be treated as a small, separate maintenance change: move or regenerate the override configuration according to the then-current pnpm documentation, regenerate the lockfile, and rerun every command in the verification matrix. pnpm’s documented remediation workflow is to update dependencies or add targeted overrides after reviewing audit findings. [1]

## Server and session hardening

The Express API accepts browser cross-origin requests only from an explicit allowlist. In production, set `CORS_ORIGINS` only if a separately hosted browser client must reach the API; provide exact comma-separated HTTPS origins. Same-origin web deployment and native clients do not need a wildcard CORS rule.

| Control | Applied policy |
|---|---|
| Response headers | `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, a restrictive `Referrer-Policy`, `Permissions-Policy`, and cross-origin resource policy are added to API responses. |
| Request volume | API requests are limited to 120 per minute per client, with bounded cleanup of inactive buckets. |
| Request body | JSON and form payloads are limited to 1 MB. Express framework identification is disabled. |
| Origin handling | Cross-origin requests must match the configured allowlist; credentials are never combined with a permissive wildcard origin. |
| Sessions | Session lifetime defaults to 30 days. Signing secrets must be at least 32 characters, and validated tokens must carry the expected application identifier. |
| Cookies | Session cookies are host-only, HTTP-only, secure on HTTPS, and use `SameSite=Lax`; cross-subdomain cookie sharing has been removed. |

## Verification matrix

Run the following commands at repository root using Node.js 22 and the repository-declared pnpm version. A constrained local runner may need `NODE_OPTIONS=--max-old-space-size=1400` for audit or install operations.

| Command | Purpose | Expected result |
|---|---|---|
| `pnpm install --frozen-lockfile` | Verify deterministic dependency installation. | Completes without modifying `pnpm-lock.yaml`. |
| `pnpm check` | Type-check Expo, server, and shared TypeScript. | Completes with no diagnostics. |
| `pnpm test -- --maxWorkers=1 --minWorkers=1` | Run deterministic mobile regression tests. | 45 passing tests and one intentional legacy skip. |
| `cd game && for t in tests/*_harness.gd; do GODOT_SILENCE_ROOT_WARNING=1 /path/to/Godot_v4.7.2-stable_linux.x86_64 --headless --path . -s "res://$t"; done` | Validate Godot systems headlessly. | All 17 harnesses pass. |
| `pnpm android:preflight` | Check Expo package compatibility and resolve the public native configuration. | Dependencies are current; version 1.0.1, Android `versionCode` 2, iOS `buildNumber` 2, and landscape orientation resolve. |
| `pnpm audit` | Recheck all resolved dependency advisories. | 0 critical, 2 high, 0 moderate, and 0 low; both high advisories are the documented unpatched `image-size` build-tool findings. |
| `pnpm audit:prod` | Recheck production dependency advisories. | Nonzero only for the documented, unpatched `image-size` build-tool advisories. |

The Expo public-config command is an appropriate pre-build inspection because `npx expo config --type public` displays the configuration that Expo will embed in builds and updates. [2]

## Android and iOS release paths

The codebase is build-ready, but Android and iOS native compilation is intentionally not performed in this sandbox because the Android SDK/Xcode toolchains and secure signing material are not available here.

### Managed build and store delivery

For a normal store-oriented Expo workflow, use the managed build service after creating a checkpoint in this workspace:

```bash
pnpm install --frozen-lockfile
pnpm android:preflight
npx eas-cli@latest build:configure
npx eas-cli@latest build --platform android
# Run separately when an iOS distribution account is available:
npx eas-cli@latest build --platform ios
```

Expo’s managed build guidance supports ready-to-submit Android and iOS binaries, and it can securely manage or accept signing credentials through the build flow. [3] Never commit keystores, provisioning profiles, signing passwords, or tokens to source control. In this managed workspace, create the checkpoint first and use the **Publish** control to start the supported release flow.

### Local Android build

On a workstation with Android Studio, Android SDK Platform 35, Android build-tools, Java 17, and `ANDROID_HOME` configured, use:

```bash
pnpm install --frozen-lockfile
pnpm android:preflight
npx expo prebuild --platform android --clean
cd android
./gradlew assembleRelease
```

The release APK is normally written below `android/app/build/outputs/apk/release/`. Configure Android release signing in the local secure-keystore workflow before distribution. The Expo app configuration controls native prebuild generation, application loading, and the update manifest, so review `app.config.ts` changes before generating native projects. [2]

## Ongoing maintenance

Review `pnpm audit --prod`, `pnpm check`, the mobile test suite, the Godot harnesses, and `pnpm android:preflight` whenever dependencies, server security code, or Expo configuration changes. Treat an Expo SDK upgrade as a coordinated migration rather than a transitive-dependency patch: regenerate the native project only when needed, validate package compatibility, and rerun the complete matrix above.

## References

[1] [pnpm Audit documentation](https://pnpm.io/cli/audit)

[2] [Expo configuration workflow documentation](https://docs.expo.dev/workflow/configuration/)

[3] [Expo managed build setup documentation](https://docs.expo.dev/build/setup/)
