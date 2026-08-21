import { describe, expect, it } from "vitest";
import { blackoutBranch, blackoutProtocolBranches, clampMissionTwoStep } from "../lib/blackout-protocol";

describe("Blackout Protocol branching mission", () => {
  it("provides two distinct persistent branch routes", () => {
    expect(blackoutProtocolBranches.map((branch) => branch.id)).toEqual(["last_platform", "static_trail"]);
    expect(blackoutBranch("static_trail")?.scenes).toHaveLength(3);
  });

  it("keeps local scene progress inside the authored mission bounds", () => {
    expect(clampMissionTwoStep(-2)).toBe(0);
    expect(clampMissionTwoStep(2.8)).toBe(2);
    expect(clampMissionTwoStep(99)).toBe(3);
  });
});
