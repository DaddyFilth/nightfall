# Blood & Brass Repository Consolidation

`DaddyFilth/nightfall` is the consolidated repository for the active **Blood & Brass** project. The repository root contains the current Expo companion application, its offline bundled assets, documentation, and build configuration.

The active native Godot campaign is located in [`game/`](./game/). Import `game/project.godot` in Godot 4.7.2; it starts at the Drowned Chart campaign hub and contains the validated ten-level first-person campaign.

The earlier root-level Godot prototype previously stored in this repository was preserved under [`legacy-godot-prototype/`](./legacy-godot-prototype/). It is retained for historical reference and is not the active Android/Expo or native campaign entry point.

| Component | Active location | Purpose |
|---|---|---|
| Expo companion | repository root | Landscape lobby, local campaign records, bundled art and audio, managed Android configuration |
| Native Godot game | `game/` | Current Blood & Brass first-person campaign and test harnesses |
| Earlier Godot prototype | `legacy-godot-prototype/` | Preserved historical prototype; not used for current builds |
| Godot handoff archive | `exports/Blood-and-Brass-Godot-Project.zip` | Clean import-ready native project handoff |

The active managed Android build is generated from the repository root through the configured EAS preview profile. Core campaign content remains packaged locally and does not require post-install downloads.
