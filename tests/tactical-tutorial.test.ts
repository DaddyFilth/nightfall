import { nextTacticalTutorialStep, shouldShowTacticalTutorial, TACTICAL_TUTORIAL_STEP_COUNT } from "../lib/tactical-tutorial";
import { describe, expect, it } from "vitest";

describe("first-run tactical tutorial", () => {
  it("opens unless the local completion flag was persisted", () => {
    expect(shouldShowTacticalTutorial(null)).toBe(true);
    expect(shouldShowTacticalTutorial("interrupted")).toBe(true);
    expect(shouldShowTacticalTutorial("completed")).toBe(false);
  });

  it("advances through each authored step before completing", () => {
    expect(TACTICAL_TUTORIAL_STEP_COUNT).toBe(3);
    expect(nextTacticalTutorialStep(0)).toBe(1);
    expect(nextTacticalTutorialStep(1)).toBe(2);
    expect(nextTacticalTutorialStep(2)).toBeNull();
  });
});
