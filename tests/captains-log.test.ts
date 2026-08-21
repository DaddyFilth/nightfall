import { captainLogForCheckpoint, captainsLogEntries } from "../lib/captains-log";
import { describe, expect, it } from "vitest";

describe("Captain’s Log cinematics", () => {
  it("provides a local spoken-log entry for each existing checkpoint cinematic", () => {
    expect(captainsLogEntries.map((entry) => entry.checkpoint)).toEqual([0, 2, 3]);
    expect(captainLogForCheckpoint(2)?.title).toBe("DOCKYARD DESCENT");
    expect(captainLogForCheckpoint(1)).toBeUndefined();
  });

  it("keeps narration transcripts substantial enough to remain readable with audio disabled", () => {
    expect(captainsLogEntries.every((entry) => entry.transcript.length > 120 && entry.deck.length > 0)).toBe(true);
  });
});
