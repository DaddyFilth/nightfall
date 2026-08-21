import { describe, expect, it } from "vitest";
import { difficultyConfig, hunterFor, hunters, weapons, weaponsForHunter } from "../lib/game-data";
import { defaultSettings, mergeSettings } from "../lib/game-session";

describe("Nightfall prototype gameplay data", () => {
  it("keeps six original vampire-pirate first-person classes available", () => {
    expect(hunters).toHaveLength(6);
    expect(new Set(hunters.map((hunter) => hunter.id)).size).toBe(6);
    expect(hunters.every((hunter) => hunter.primaryWeapon.length > 0 && hunter.secondaryWeapon.length > 0 && hunter.fightingStyle.length > 0)).toBe(true);
  });

  it("provides a safe default hunter for an unavailable selection", () => {
    expect(hunterFor("unavailable" as never).id).toBe("duskstalker");
  });

  it("increases local encounter pressure across difficulty levels", () => {
    expect(difficultyConfig.Initiate.target).toBeLessThan(difficultyConfig.Nightmare.target);
    expect(difficultyConfig.Nightmare.enemyHit).toBeLessThan(difficultyConfig.Eclipse.enemyHit);
  });

  it("exposes two original weapons for every class without monetized stat data", () => {
    expect(weapons).toHaveLength(12);
    expect(weapons.every((weapon) => weapon.name.length > 0 && weapon.note.length > 0)).toBe(true);
    for (const hunter of hunters) {
      const loadout = weaponsForHunter(hunter.id);
      expect(loadout).toHaveLength(2);
      expect(loadout.map((weapon) => weapon.name)).toEqual([hunter.primaryWeapon, hunter.secondaryWeapon]);
    }
  });

  it("merges persisted accessibility changes without losing the default controls", () => {
    expect(mergeSettings({ reducedMotion: true, sensitivity: 80 })).toEqual({
      ...defaultSettings,
      reducedMotion: true,
      sensitivity: 80,
    });
  });
});
