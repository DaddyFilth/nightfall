import { describe, expect, it } from "vitest";
import { isStoryMissionDefeated, isStoryMissionUnlocked, normalizeStoryDefeatedThrough } from "../lib/story-progression";

describe("strict story progression", () => {
  it("opens chapters only after the immediately prior mission is defeated", () => {
    expect(isStoryMissionUnlocked(1, 0)).toBe(true);
    expect(isStoryMissionUnlocked(2, 0)).toBe(false);
    expect(isStoryMissionUnlocked(2, 1)).toBe(true);
    expect(isStoryMissionUnlocked(3, 1)).toBe(false);
    expect(isStoryMissionUnlocked(3, 2)).toBe(true);
		expect(isStoryMissionUnlocked(10, 8)).toBe(false);
		expect(isStoryMissionUnlocked(10, 9)).toBe(true);
  });

	it("keeps defeated progress within the authored ten-mission campaign", () => {
    expect(normalizeStoryDefeatedThrough(-4)).toBe(0);
    expect(normalizeStoryDefeatedThrough(1.9)).toBe(1);
    expect(normalizeStoryDefeatedThrough(99)).toBe(10);
    expect(isStoryMissionDefeated(2, 1)).toBe(false);
    expect(isStoryMissionDefeated(2, 2)).toBe(true);
  });
});
