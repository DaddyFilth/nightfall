import { clampDemoStage, demoStageAt, demoStages, nextDemoStage } from "../lib/demo-mode";
import { describe, expect, it } from "vitest";

describe("guided demo mode", () => {
  it("covers combat, campaign, multiplayer, boss, and cosmetic collection in order", () => {
    expect(demoStages.map((stage) => stage.id)).toEqual(["briefing", "combat", "campaign", "modes", "windup", "conductor", "collection"]);
  });
  it("keeps automatic and manual advancement inside the demo bounds", () => {
    expect(clampDemoStage(-4)).toBe(0);
    expect(nextDemoStage(0)).toBe(1);
    expect(nextDemoStage(999)).toBe(demoStages.length - 1);
    expect(demoStageAt(999).id).toBe("collection");
  });
});
