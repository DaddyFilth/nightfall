import { describe, expect, it } from "vitest";

import { defaultSettings, mergeSettings } from "../lib/game-session";

describe("local audio settings", () => {
  it("starts with restrained dockyard ambience and interface sounds enabled", () => {
    expect(defaultSettings.ambientMusic).toBe(true);
    expect(defaultSettings.interfaceSounds).toBe(true);
    expect(defaultSettings.musicVolume).toBe(34);
  });

  it("preserves saved audio preferences while supplying defaults for older local profiles", () => {
    const restored = mergeSettings({ ambientMusic: false, musicVolume: 60 });

    expect(restored.ambientMusic).toBe(false);
    expect(restored.musicVolume).toBe(60);
    expect(restored.interfaceSounds).toBe(true);
  });
});
