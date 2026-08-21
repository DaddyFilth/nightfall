# Blood & Brass Offline APK Content Policy

Blood & Brass packages its core companion and native-campaign content with the installed build. The app does not fetch campaign art, Captain’s Log narration, high-resolution harbor artwork, Godot scene logic, procedural presentation code, puzzle gates, enemy behavior, or boss hazards during normal play.

| Content surface | Packaging boundary |
|---|---|
| Companion illustrations and heraldry | Static application assets referenced with `require(...)` and included by Metro in the Android/iOS build. |
| Captain’s Log narration | Bundled MP3 assets prepared locally using the Expo asset system. |
| Harbor artwork | Bundled PNG asset prepared locally using the Expo asset system. |
| Godot campaign graphics and animation | Authored scenes, scripts, procedural meshes/materials, and the bundled dockyard texture included by the Godot Android preset’s **Export all resources** mode. |
| Local campaign records | Device-local JSON exported or shared only at the player’s request; no cloud synchronization occurs. |

The app can still open the platform share sheet for a player-initiated completion record. That action hands a local JSON file to the operating system; it is not a resource download or a dependency for gameplay.

## Asset verification

The bundled Captain portrait was visually verified after mobile-focused optimization at **720 × 1280** pixels (approximately **542 KB**), retaining the character silhouette, sail rigging, gothic port, and dark crimson/brass palette. The bundled harbor panorama was visually verified at **1280 × 720** pixels (approximately **490 KB**), retaining the crane, galleon, eclipse, wet dock, and skyline composition. These dimensions keep the two APK-contained images below the project checkpoint threshold without moving them to remote storage.

> Future content additions require a new signed app build. They are not delivered as runtime resource packs.
