# Platform-Safe Preference File Bridge Blueprint

The Godot project now provides a **local user-sandbox file bridge** that is safe to exercise during native development. It only accepts one fixed inbox path, parses JSON, validates the `nightfall.godot-preferences.v1` contract, writes through a temporary file, and replaces the active local payload only after validation succeeds.

| Local path | Role | Safety behavior |
|---|---|---|
| `user://nightfall/import/expo-preferences.v1.json` | Approved inbox inside the Godot application sandbox | Only this exact payload name is read. |
| `user://nightfall/expo-preferences.v1.json` | Validated active preferences | Replaced through a temporary file only after schema validation. |

The bridge is a **blueprint**, not a completed cross-runtime product integration. Expo and Godot have separate application sandboxes by default. A real signed iOS or Android delivery must introduce a platform-approved handoff mechanism that copies or exposes a payload from a host-owned location into the Godot sandbox, then test the complete path on physical devices. This project neither signs a build nor claims that the two runtimes can currently read each other’s private files.

