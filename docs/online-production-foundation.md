# Online Production Foundation

This repository now contains a **Godot 4 compatible foundation** under `/game` and an Expo-facing production-readiness contract. It is not yet an internet-released multiplayer game because no Steam, Google Play, App Store, or AdMob credentials have been configured and no signed native mobile build has been tested.

## Match Authority

The temporary lobby host owns match time, health, score, deaths, and end-of-match state. Client peers submit sequence-numbered movement and aim intents on an unreliable ordered channel, while lobby, ability, score, and result events use reliable RPCs. The host rejects missing player state, duplicate sequences, out-of-range movement, stale timestamps, excessive input rate, invalid ability range, and unregistered players. Godot supports this separation through authority-qualified RPCs, transfer modes, and independent channels.[1]

| Mode | Players | Rule | Authority-owned outcome |
|---|---:|---|---|
| **Blood Hunt (FFA)** | 2–8 | First to 30 eliminations or highest score after 8 minutes. | Kills, deaths, respawns, score, match result. |
| **Crimson Accord (TDM)** | 2–8 | Two teams race to 50 eliminations in 10 minutes. | Teams, respawns, score, match result. |
| **Relic Run (CTF)** | 2–8 | Two teams return three opposing eclipse relics in 12 minutes. | Relic state, captures, score, match result. |

The included ENet adapter is for LAN/editor development. The Steam P2P adapter intentionally fails closed until a reviewed GodotSteam/Steam Networking Sockets native extension and `STEAM_APP_ID` are installed. Do not expose player IP addresses in UI, analytics, results, or user-facing logs. A later dedicated-server migration can preserve the same intent/RPC contract while replacing the temporary lobby host.

## Entitlements and Advertisements

The backend accepts a conceptual receipt submission only after a platform-specific verifier is configured. Android verification requires a package name and service-account material so the backend can inspect the submitted purchase token through the Google Play Developer API.[2] iOS verification requires an App Store Connect issuer, key ID, private key, and bundle identifier so the backend can call the App Store Server API with signed JWT authorization.[3]

Advertising remains disabled until the User Messaging Platform reports current consent. The native SDK must refresh consent each launch, display any required message before ad requests, and provide an available privacy-options control whenever required.[4] The placement contract allows a banner only on the main menu or completed-results screen for eligible free mobile users. It disallows every ad during combat, pause, checkpoint, matchmaking, connection failure, and checkout.

## Required Activation Inputs

| Capability | Required configuration | Safe behavior before configuration |
|---|---|---|
| Steam P2P | Steam App ID plus reviewed native Godot transport extension. | Adapter returns unavailable; no claimed online P2P. |
| Google Play verification | Package name and service-account JSON with Play Developer API access. | Android receipt is rejected as unconfigured. |
| App Store verification | Bundle ID, issuer ID, key ID, and App Store Connect private key. | iOS receipt is rejected as unconfigured. |
| Android ads | AdMob app ID and production placement IDs. | No ad SDK initialization or request. |
| iOS ads | AdMob app ID and production placement IDs. | No ad SDK initialization or request. |

## References

[1] [Godot Engine — High-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)

[2] [Google Play Developer API — purchases.products.get](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.products/get)

[3] [Apple Developer — App Store Server API](https://developer.apple.com/documentation/appstoreserverapi)

[4] [Google AdMob — Set up UMP SDK](https://developers.google.com/admob/android/privacy)

[5] [Godot Engine — Download for Linux](https://godotengine.org/download/linux/)

## Local Godot Validation Runtime

The official Godot Linux download is self-contained: its instructions are to extract the published x86_64 archive and run the executable.[5] The local harness will use that runtime only to parse and execute the repository’s Godot 4 project and to exercise ENet host/client behavior on loopback or a LAN. Passing such a harness validates local transport wiring; it does **not** validate public matchmaking, NAT traversal, Internet P2P, Steam Datagram Relay, store billing, or mobile export.

The project was parsed headlessly with **Godot 4.7.2** and the local loopback harness passed: an ENet server and client negotiated successfully on `127.0.0.1:18873` in three frames. The test uses the underlying `ENetConnection` returned by `ENetMultiplayerPeer.get_host()` to confirm the server sees its connected client, consistent with the engine’s ENet API.[6]

The same local runtime now validates **Crimson Accord** Team Deathmatch and **Relic Run** Capture the Flag rules. The authority assigns teams, rejects friendly-fire scores, owns team score totals, requires an enemy relic before capture, rejects a return to the enemy sanctuary, and concludes each mode only at its configured score or capture limit. The rule harness completed with `LOCAL_MODES_PASS`; it does not validate client movement, collision overlap, anti-cheat, public matchmaking, or a networked lobby.

The Godot vertical slice now has an original procedural 3D **Nocturne rail station** presentation scene. It builds its floor, rails, service pillars, cover, eclipse engine, lighting, and four stylized Hollowed enemy actors from in-engine primitives. The Hollowed use simple original idle hover, rotation, halo pulse, and attack-pulse states; the presentation harness completed with `ARENA_PRESENTATION_PASS geometry=procedural enemies=4`. These are in-engine prototype assets, not imported or licensed third-party models, animation clips, audio, or level content.

The Expo single-player path now pauses at the mission start and after each secured Ashes Below checkpoint for a local animated story interlude. The archive contains three timestamped timeline events, each with contextual narration and a transmission that leads into the next objective. These overlays are UI-based prototype cinematics; they are not a claim of voiced, motion-captured, pre-rendered, or Godot-exported cutscenes. The detailed script is recorded in `docs/ashes-below-story-script.md`.

The Godot arena now uses physics collision for player constraints and projectile resolution. `NightfallPlayer` uses a capsule `CharacterBody3D` that collides with the solid floor, platform walls, pillars, and cover. Projectiles ray-test along their travelled segment, stop on solid geometry, and dispatch a bounded damage payload only to registered Hollowed hurtboxes. The native harness completed with `COLLISION_PROJECTILE_PASS player=constrained target_damage=25 solid_blocked=true`; this validates deterministic local geometry and target hits, not input devices, animation blending, latency compensation, or network authority.

Mission Two, **Blackout Protocol**, now adds two locally persistent branching routes in the mobile campaign: **The Last Platform** and **Following Static**. Each route has three authored objective scenes and a distinct branch outcome that can seed a future Observatory briefing. This is a local campaign decision record only; it does not claim cloud saves, native Godot save interoperability, or a production campaign service. The full branch script is recorded in `docs/blackout-protocol-branch-script.md`.

The Godot Hollowed is now an original low-poly multi-part creature mesh with a local ultraviolet-and-crimson gradient material texture, a capsule hurtbox, and authored **idle**, **pursuit**, **attack**, **hit**, and **dissolve** state behavior. The Arsenal screen includes the generated original material direction as a visual dossier; the Godot runtime remains self-contained by using its own procedural material asset rather than fetching an external image at play time. The collision harness confirms a projectile moves the target into its `hit` state after applying its bounded local damage.

The Godot player now registers and consumes local **keyboard**, **gamepad**, and **touch** input. The on-screen overlay provides a movement disc, fire control, and Veil control; the gamepad maps left stick to movement, right stick to aim, right shoulder to fire, and A to Veil. The input harness completed with `INPUT_HARNESS_PASS touch=virtual gamepad=mapped keyboard=mapped`. This validates action registration and local virtual-touch movement, not a physical controller, a signed Android/iOS touch build, remapping UI, or networked input authority.

Mission Three, **The Observatory**, now reads the locally saved Blackout Protocol branch. The Last Platform route enters through a survivor-mapped service corridor and preserves civic-trust context; Following Static enters through an exposed relay-lattice gap and preserves tactical-intelligence context. Both routes have three persisted operations before arriving at the same relay-core floor. The detailed convergence script is recorded in `docs/observatory-convergence-script.md`; it remains a device-local mobile mission presentation rather than a shipped 3D Godot campaign mission.

The Godot arena now includes a self-contained procedural audio layer. It synthesizes short original tonal cues for projectile fire, target and solid impacts, Hollowed attack/hit/dissolve states, and an opening cinematic transition. The scene wires cues to actual local player, projectile, and actor events. `AUDIO_HARNESS_PASS cues=6 source=procedural_local` validates the cue profiles and dispatch behavior; stream creation is intentionally disabled in headless validation only, while local runtime builds retain the audio generator. This is not a replacement for authored sound design, voice acting, spatial mixing, accessibility captions for sound, or native-device audio testing.

The Godot vertical slice now also includes an original 3D **Observatory** arena. It builds a shared relay-core floor and chooses a collision-aware entry assembly from an explicit local branch value: **Civic Service Entry** uses cyan guidance, service doors, and a caretaker route for The Last Platform; **Lattice Gap Entry** uses crimson lattice frames, a cipher window, and a narrow route for Following Static. The native arena harness completed with `OBSERVATORY_ARENA_PASS branches=civic_service,lattice_gap geometry=distinct`. A future mobile-to-Godot bridge must pass the persisted Expo branch into this local scene; that bridge is not represented as production save interoperability.

The mobile controls screen now persists aim sensitivity, handedness, a primary touch-action default, audio-cue subtitles, and vibration preference. Each of the seven local Godot cues has a matching title and text callout. At the Godot layer, every cue emits optional subtitle and vibration signals and each presentation arena exposes a visual caption label. `AUDIO_HARNESS_PASS` validates all six cue profiles and confirms that both signals honor disabled toggles. The current Expo settings screen and Godot flags are deliberately separate local profiles until a future signed-build bridge connects them; no account, cloud, or cross-runtime synchronization is claimed.

The native Godot layer now supports explicit **gamepad button capture** for the Fire and Veil actions. During a capture window, a pressed joypad button replaces only the existing joypad button binding for that one action; the new mapping is stored under `user://nightfall/gamepad-bindings.v1.cfg` and reloaded locally. `GAMEPAD_REMAP_PASS action=fire button=x persistence=local` validates capture and persistence. This is an in-engine local feature, not an Expo-web gamepad listener, a full remapping UI, a cross-device profile, or a signed-device test.

The Observatory arena now includes a branch-configured Conductor boss prototype. The civic route changes its three phases to Beacon Sanctuary, Evacuation Mirrors, and Last Train Reversal; the cipher route changes them to Thirteenth Pulse, Lattice Scission, and Cipher Overload. On defeat, the local prototype yields only a branch-themed cosmetic designation—Civic Wayfinder or Relay Breaker—and the mobile Observatory completion panel displays the matching reward. `OBSERVATORY_CONDUCTOR_PASS branches=civic,cipher rewards=cosmetic_only` validates the phase and non-advantage reward contracts. The detailed design is recorded in `docs/observatory-conductor-design.md`.

The Godot station presentation now includes a visual **Gamepad Rebinding** prompt. It shows the action being captured, identifies a conflicting action if a selected button is already assigned, and requires an explicit replacement confirmation before moving that button to the requested action. The native input harness validates the full flow: `GAMEPAD_REMAP_PASS action=fire,ability button=x conflict=replaced persistence=local`. This is a local Godot visual prompt only; it does not capture a browser gamepad, provide a complete settings screen, or validate real-device controller hardware.

The Observatory Conductor now has a live target-layer hurtbox linked to the existing projectile raycast contract. A player projectile applies bounded damage, drives the Conductor’s phase bands, flashes the boss shell, and updates a phase-mechanic telegraph in the arena. `CONDUCTOR_PROJECTILE_PASS hurtbox=live damage=25 telegraph=phase_two` validates this local hit path. The prototype does not yet connect user input to a real mobile camera, animate mechanical attacks, establish multiplayer authority, or deliver combat rewards through a production inventory.

[6] [Godot Engine — ENetMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html)
