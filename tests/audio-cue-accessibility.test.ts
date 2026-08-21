import { describe, expect, it } from "vitest";
import { audioCueAccessibility } from "../lib/audio-cue-accessibility";
import { defaultSettings, mergeSettings } from "../lib/game-session";

describe("audio cue accessibility", () => {
  it("provides a subtitle and vibration profile for every procedural Godot cue", () => {
    expect(audioCueAccessibility.map((cue) => cue.id)).toEqual(["projectile_fire", "impact_target", "impact_solid", "enemy_attack", "enemy_hit", "enemy_dissolve", "cinematic_transition"]);
    expect(audioCueAccessibility.every((cue) => cue.subtitle.length > 0 && cue.haptic.length > 0)).toBe(true);
  });

  it("preserves new remapping and audio accessibility defaults for earlier local profiles", () => {
    const merged = mergeSettings({ sensitivity: 80 });
    expect(merged).toMatchObject({ ...defaultSettings, sensitivity: 80, touchLayout: "right_handed", touchPrimaryAction: "fire", vibration: true, audioCueSubtitles: true });
  });
});
