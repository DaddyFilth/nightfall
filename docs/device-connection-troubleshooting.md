# Device Connection Troubleshooting

## Socket-exemption or HTTP timeout during development

Blood & Brass has no runtime network requirement for its core campaign, artwork, Captain’s Log narration, local completion records, or Godot handoff. A `SocketTimeoutException`, an HTTP timeout, or a socket-exemption message while opening the project through **Expo Go** normally means that the phone cannot reach the Metro development server. It does not indicate that the packaged game assets need to download.

| Situation | Recommended command | Device requirement |
|---|---|---|
| Computer and phone share the same local network | `pnpm dev:lan` | Keep both devices on the same Wi-Fi network; disable mobile-data fallback while testing. |
| Campus, hotel, corporate, guest, or isolated Wi-Fi | `pnpm dev:tunnel` | Internet access is required only for development transport; scan the newly shown Expo QR code. |
| Installed preview/release APK | No Metro command required | Launch the installed build directly. Core campaign media is already bundled. |
| Godot handoff APK | No Expo command required | Export and install the Godot APK from the handoff project; its scene resources are local. |

> Do not scan an old QR code after switching modes. Stop the previous Expo session, run one of the commands above, and scan the new QR code shown in that terminal.

The managed browser preview intentionally uses `pnpm dev`, which starts Expo in web mode for the project workspace. Use `pnpm dev:lan` or `pnpm dev:tunnel` only when testing with Expo Go on a physical device. The tunnel option avoids a direct phone-to-`localhost` path and is the preferred workaround when the device reports an HTTP socket timeout.

## If the error occurs in an installed APK

An installed preview or release APK should not attempt to reach Metro. Confirm that the app was installed from its finished APK artifact rather than opened through Expo Go. If the message still appears, capture the entire error text and the screen where it occurs; include whether the app is the Expo companion, the React Native preview APK, or a Godot APK. That identifies the failing transport without changing the offline campaign boundary.
