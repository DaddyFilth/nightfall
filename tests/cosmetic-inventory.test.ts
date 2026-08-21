import { describe, expect, it } from "vitest";
import { normalizeEquippedCosmetics, normalizeInventory, rewardIdForBranch } from "../lib/cosmetic-inventory";

describe("cosmetic inventory", () => {
  it("maps Observatory branches only to cosmetic reward identifiers", () => {
    expect(rewardIdForBranch("last_platform")).toBe("civic_wayfinder");
    expect(rewardIdForBranch("static_trail")).toBe("relay_breaker");
    expect(rewardIdForBranch(null)).toBeUndefined();
  });
	it("removes unsupported stored inventory entries", () => {
		expect(normalizeInventory(["civic_wayfinder", "unknown", 9])).toEqual(["civic_wayfinder"]);
	});
	it("keeps equipment only when its title and banner are both earned", () => {
		expect(normalizeEquippedCosmetics({ title: "civic_wayfinder", banner: "relay_breaker" }, ["civic_wayfinder"])).toEqual({ title: "civic_wayfinder", banner: null });
		expect(normalizeEquippedCosmetics({ title: "relay_breaker", banner: "civic_wayfinder" }, ["civic_wayfinder", "relay_breaker"])).toEqual({ title: "relay_breaker", banner: "civic_wayfinder" });
	});
});
