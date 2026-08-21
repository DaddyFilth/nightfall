# Blood & Brass — Godot Project Handoff

This folder is a native **Godot 4** project for the playable Blood & Brass first-person campaign. It contains a ten-level interactive FPS roster, local campaign-progress and checkpoint systems, touch and gamepad input systems, presentation scripts, test harnesses, and mobile-bridge contracts.

> **Godot projects are imported locally through the Godot Project Manager.** No Godot account is required to open this package. If a separate service asks you to upload a project, upload the extracted folder that contains `project.godot`.

## Open in Godot

1. Download and extract the handoff ZIP without changing its folder structure.
2. Open **Godot 4.7.2** or a compatible Godot 4.x editor.
3. In the Project Manager, select **Import**, choose the extracted `project.godot`, then select **Import & Edit**.
4. Press **F6** to run the current scene or **F5** to open the configured campaign hub, `scenes/campaign_hub.tscn`.
5. Godot will regenerate the excluded `.godot/` editor cache automatically on first import.

## Interactive content included

| Surface | What to test |
|---|---|
| Ten-level FPS campaign | The Drowned Chart hub deploys ten animated first-person levels from **Ashes Below** through **Blood & Brass**. Each level has a distinct animated visual signature, objective route, hostile encounter loop, and boss-resolution state. |
| Checkpoint objectives | Every checkpoint begins behind an in-world puzzle gate. Levels use authored ordered-rune, correct-route, core-charging, and binary-switch objectives; prompts and object geometry explain the rule, while a wrong attempt resets only that short local puzzle. |
| Mission encounters | Each campaign level selects an authored boss title, three named attacks, an animated traversal set piece, a local dodgeable arena hazard, and a hostile mix. Later levels introduce Harpoon Raiders, Lantern Wisps, Iron Abbots, Coffin Marines, Bell Tollkeepers, Meridian Sentinels, and Leviathan Guards. |
| Brasswake combat | First-person Captain camera, wheel-lock/cutlass viewmodel, centered reticle, two-thumb touch control, advancing privateers, Drowned Admiral encounter, victory and defeat states. |
| Campaign rules | First-to-last mission progression across all ten levels, plus device-local checkpoint persistence and mission gating. |
| Controls | Touch layout plus local gamepad/keyboard mappings and rebinding foundations. |
| Presentation | Original procedural dockyard/Observatory presentation, a bundled dockyard artwork backdrop, visible first-person viewmodel, actors, ambient audio hooks, animated sails/fog/spray/sparks, and combat feedback. |
| Native bridges | Android/iOS preference-bridge contracts for a future signed native integration; these are source contracts, not compiled platform binaries. |

## Touch controls

The `NightfallTouchOverlay` receives real touch input globally, so it remains responsive above the 3D scene. The movement stick sits lower-left with a generous capture radius, letting a thumb settle naturally before dragging. The right-hand action cluster uses larger, separated **FIRE**, **VEIL**, and **DODGE** targets with expanded hit areas and active press feedback. On landscape phones and tablets, the layout scales from the shorter screen edge and keeps an inset away from the bezel.

Use the movement stick to drive the Captain. Drag the clear upper-right play space to turn the first-person camera; the centered reticle indicates the wheel-lock’s true firing line. Tap **FIRE** to use the wheel-lock, **VEIL** to trigger the Captain ability, and **DODGE** to enter the dodge window. Gamepad right-stick aiming and keyboard action mappings remain available for desktop testing.

The visible weapon is an original first-person Bloodwake viewmodel: a brass wheel-lock and boarding cutlass with recoil and swing feedback. The third-person Captain mesh is intentionally hidden during normal FPS play so it cannot clip through the camera.

Hold **FIRE** to settle the wheel-lock into its aim-down-sights presentation; releasing it restores the wide combat view. Every shot begins a short reload lockout with a visible wheel-lock manipulation and a local audio cue. The **FPS OPTIONS** panel in combat stores look sensitivity from **0.50×** to **2.00×** and vertical-inversion preference at `user://nightfall/fps-settings.v1.cfg`.

## Campaign roster

| Level | Mission | Checkpoints | Native scene |
|---:|---|---:|---|
| 01 | Ashes Below | 3 | `brasswake_combat.tscn` |
| 02 | The Broken Compass | 4 | `the_broken_compass.tscn` |
| 03 | The Observatory | 4 | `the_observatory_campaign.tscn` |
| 04 | Sable Wake | 5 | `sable_wake.tscn` |
| 05 | Lanterns of the Lost | 3 | `lanterns_of_the_lost.tscn` |
| 06 | Iron Cathedral | 6 | `iron_cathedral.tscn` |
| 07 | Coffin Fleet | 4 | `coffin_fleet.tscn` |
| 08 | The Thirteenth Bell | 5 | `the_thirteenth_bell.tscn` |
| 09 | Red Meridian | 4 | `red_meridian.tscn` |
| 10 | Blood & Brass | 6 | `blood_and_brass_finale.tscn` |

Run levels through the **Drowned Chart** hub rather than directly if you want the normal unlock rules. Individual scene execution is useful for editor iteration, while the hub enforces the intended campaign order.

## Local companion completion record

When a native level is defeated, Godot writes a bounded local record at `user://nightfall/export/campaign-completion.v1.json`. The mission-resolution panel exposes **EXPORT COMPLETION RECORD** to regenerate this file after a victory. In the companion app, use **Story → Sync / Export Local Completion** to import the file, or export/share an already imported record through the operating system's share sheet on supported Android and iOS devices. The app validates the schema and only raises its local completed-mission boundary; it never uploads campaign data or requires an account, external API, or secret.

The Brasswake arena uses a grounded original tactical-action composition: shadowed moonlight, warm brass key lighting, sea-teal rim light, localized sea-fog fill, wet deck details, layered deck seams, cargo-face plating, cargo cover, a bundled original dockyard-art backdrop, ember-like atmospheric particles, pulsing eclipse-core light, and a tighter combat camera. Sails, fog, lanterns, sparks, eclipse pulse, weapon recoil/reload, and enemy state motion are initialized by the native scene and tested for visible runtime movement. The materials use restrained rim and clear-coat response to strengthen silhouette separation and wet-metal depth without requiring an external texture download. These elements are original to Blood & Brass and do not copy third-party game assets or branding.

## Offline APK resources

All authored campaign scenes, scripts, procedural meshes, materials, bundled dockyard texture, touch HUD, puzzle logic, boss hazards, and local audio hooks live in this project and should be exported with the APK. In the Godot Android export preset, set **Resources → Export Mode** to **Export all resources in the project**. Do not select a filter that excludes `assets/`, `scenes/`, or `scripts/`.

The companion application also bundles its campaign illustrations, Captain’s Log narration, and high-resolution harbor artwork through static application assets. Its **Bundled Campaign Media** screen is an inventory of APK-contained media, not a download manager. Core campaign play does not require a network connection after installation.

## Headless validation

From the extracted project folder, run each harness with the Godot executable available on your machine:

```bash
for t in tests/*_harness.gd; do
  godot --headless --path . -s "res://$t"
done
```

The packaged project deliberately excludes `.godot/`, which is editor-generated cache data. All authored scenes, scripts, tests, project settings, bundled texture assets, and native-adapter source contracts are included.

## Android export

For a local Android APK, install matching Godot export templates, configure OpenJDK and the Android SDK in Editor Settings, then create the Android export preset locally. The project does not ship a keystore or a machine-specific `export_presets.cfg`. See [`ANDROID_EXPORT_SETUP.md`](ANDROID_EXPORT_SETUP.md) for the exact remediation steps for missing `android_source.zip`, Java, SDK `platform-tools`/`build-tools`, and release-keystore errors.

## Integration boundary

This project is an original offline vertical slice. LAN/game-mode simulations and mobile bridge adapters remain local foundations; production Internet matchmaking, store billing, ads, and platform-specific framework compilation require separate platform configuration and review.
