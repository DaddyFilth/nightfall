import { describe, expect, it } from "vitest";
import { buildGodotPreferenceHandoff, GODOT_PREFERENCE_HANDOFF_SCHEMA, isGodotPreferenceHandoff } from "../lib/godot-preference-handoff";
import { defaultSettings } from "../lib/game-session";

describe("Godot preference handoff", () => {
  it("builds a bounded local payload that carries mobile accessibility and branch context", () => {
    const payload = buildGodotPreferenceHandoff({ ...defaultSettings, sensitivity: 110, touchLayout: "left_handed", vibration: false }, "static_trail");
    expect(payload).toMatchObject({ schema: GODOT_PREFERENCE_HANDOFF_SCHEMA, preferences: { sensitivity: 100, touchLayout: "left_handed", vibration: false }, campaign: { observatoryBranch: "static_trail" } });
    expect(isGodotPreferenceHandoff(payload)).toBe(true);
  });

  it("rejects objects that do not represent the v1 handoff shape", () => {
    expect(isGodotPreferenceHandoff({ schema: "other", preferences: {}, campaign: {} })).toBe(false);
  });
});
