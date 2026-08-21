import { describe, expect, it } from "vitest";
import { ashesBelowStages, nextCheckpoint, stageAt } from "../lib/ashes-below";

describe("Ashes Below progression", () => {
  it("contains a four-stage mission ending with the Conductor", () => {
    expect(ashesBelowStages).toHaveLength(4);
    expect(ashesBelowStages.at(-1)?.id).toBe("conductor-core");
  });

  it("keeps checkpoint indexes inside the playable mission", () => {
    expect(nextCheckpoint(1)).toBe(2);
    expect(nextCheckpoint(99)).toBe(3);
    expect(stageAt(-5).id).toBe("signal-platform");
  });

  it("records two local save checkpoints before the boss", () => {
    expect(ashesBelowStages.filter((stage) => stage.checkpointAfter).map((stage) => stage.id)).toEqual(["maintenance-spine", "furnace-lift"]);
  });
});
