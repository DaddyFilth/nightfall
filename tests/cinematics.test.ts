import { describe, expect, it } from "vitest";
import { ashesBelowCinematics, cinematicForCheckpoint } from "../lib/ashes-below-cinematics";

describe("Ashes Below cinematics", () => {
  it("provides original timeline scenes for the opening and saved checkpoints", () => {
    expect(ashesBelowCinematics.map((scene) => scene.checkpoint)).toEqual([0, 2, 3]);
    expect(cinematicForCheckpoint(2)?.headline).toContain("MAINTENANCE SPINE");
  });

  it("keeps each cinematic playable as an explicit context scene", () => {
    expect(ashesBelowCinematics.every((scene) => scene.timestamp.length > 0 && scene.context.length > 80 && scene.transmission.length > 20)).toBe(true);
    expect(cinematicForCheckpoint(1)).toBeUndefined();
  });
});
