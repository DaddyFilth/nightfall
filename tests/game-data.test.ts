import { describe, expect, it } from "vitest";
import { difficultyConfig, hunterFor, hunters, weapons } from "../lib/game-data";
import { defaultSettings, mergeSettings } from "../lib/game-session";

describe("Nightfall prototype gameplay data", () => {
  it("keeps four original vampire subclasses available", () => {
    expect(hunters).toHaveLength(4);
    expect(new Set(hunters.map((hunter) => hunter.id)).size).toBe(4);
  });

  it("provides a safe default hunter for an unavailable selection", () => {
    expect(hunterFor("unavailable" as never).id).toBe("duskstalker");
  });

  it("increases local encounter pressure across difficulty levels", () => {
    expect(difficultyConfig.Initiate.target).toBeLessThan(difficultyConfig.Nightmare.target);
    expect(difficultyConfig.Nightmare.enemyHit).toBeLessThan(difficultyConfig.Eclipse.enemyHit);
  });

  it("exposes an original starting weapon set without monetized stat data", () => {
    expect(weapons).toHaveLength(5);
    expect(weapons.every((weapon) => weapon.name.length > 0 && weapon.note.length > 0)).toBe(true);
  });

  it("merges persisted accessibility changes without losing the default controls", () => {
    expect(mergeSettings({ reducedMotion: true, sensitivity: 80 })).toEqual({
      ...defaultSettings,
      reducedMotion: true,
      sensitivity: 80,
    });
  });
});
