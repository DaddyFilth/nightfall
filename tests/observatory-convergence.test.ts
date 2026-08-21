import { describe, expect, it } from "vitest";
import { clampObservatoryStep, observatoryRoute, observatoryRoutes } from "../lib/observatory-convergence";

describe("Observatory convergence", () => {
  it("preserves a distinct entry route for both Blackout Protocol outcomes", () => {
    expect(observatoryRoutes).toHaveLength(2);
    expect(observatoryRoute("last_platform")?.advantage).toContain("CIVIC TRUST");
    expect(observatoryRoute("static_trail")?.advantage).toContain("LATTICE WEAKNESS");
  });

  it("keeps saved convergence progress within the three authored operations", () => {
    expect(clampObservatoryStep(-1)).toBe(0);
    expect(clampObservatoryStep(2.9)).toBe(2);
    expect(clampObservatoryStep(8)).toBe(3);
  });
});
