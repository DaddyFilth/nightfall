import { describe, expect, it } from "vitest";

import { weapons } from "../lib/game-data";
import { weaponTelemetryFor } from "../lib/weapon-telemetry";

describe("weapon telemetry", () => {
  it("provides three readable combat-stat field notes for every original weapon", () => {
    for (const weapon of weapons) {
      const telemetry = weaponTelemetryFor(weapon.name);
      expect(telemetry.profile.length).toBeGreaterThan(0);
      expect(telemetry.stats).toHaveLength(3);
      for (const stat of telemetry.stats) {
        expect(stat.value).toBeGreaterThanOrEqual(0);
        expect(stat.value).toBeLessThanOrEqual(100);
        expect(stat.fieldNote.length).toBeGreaterThan(12);
      }
    }
  });
});
