import { describe, expect, it } from "vitest";
import { observatoryReward, observatoryRewards } from "../lib/observatory-rewards";

describe("Observatory rewards", () => {
  it("keeps both branch rewards cosmetic and non-pay-to-win", () => {
    expect(observatoryRewards).toHaveLength(2);
    expect(observatoryReward("last_platform")?.title).toBe("CIVIC WAYFINDER");
    expect(observatoryReward("static_trail")?.detail).toContain("no stat");
  });
});
