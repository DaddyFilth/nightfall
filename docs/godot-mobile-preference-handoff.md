# Expo-to-Godot Local Preference Handoff

The project defines a **versioned local file contract** for a future signed Godot mobile export. Expo builds a deterministic `nightfall.godot-preferences.v1` payload from its locally stored settings and the selected Observatory campaign branch. Godot validates the same schema before applying audio-caption and vibration flags or selecting an Observatory entry branch.

| Payload group | Included values | Intended Godot consumer |
|---|---|---|
| `preferences` | Sensitivity, motion, reticle, color, subtitle, vibration, handedness, and primary action defaults | Touch presentation, accessibility captions, local audio, and input setup. |
| `campaign` | `last_platform`, `static_trail`, or `null` | Observatory entry configuration. |

The contract does not itself transfer data between Expo and Godot. A signed mobile build must implement a platform-approved handoff step, such as a shared app-group file, an approved import workflow, or a host-owned bridge, and must test that behavior on real devices. No cross-runtime synchronization, signing, export, account connection, or cloud save is represented by this local schema alone.

