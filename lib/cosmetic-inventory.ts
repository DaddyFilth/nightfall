import type { MissionTwoBranchId } from "@/lib/blackout-protocol";

export type CosmeticRewardId = "civic_wayfinder" | "relay_breaker";
export type CosmeticInventoryItem = { id: CosmeticRewardId; title: string; item: string; branch: MissionTwoBranchId; description: string; color: string };
export type EquippedCosmetics = { title: CosmeticRewardId | null; banner: CosmeticRewardId | null };

export const cosmeticInventory: CosmeticInventoryItem[] = [
  { id: "civic_wayfinder", title: "CIVIC WAYFINDER", item: "Platform Keeper Banner", branch: "last_platform", description: "Earned for bringing the Last Platform route through the Observatory. Cosmetic profile designation only.", color: "#3DE6E6" },
  { id: "relay_breaker", title: "RELAY BREAKER", item: "Cipher Halo Frame", branch: "static_trail", description: "Earned for taking Following Static through the Observatory. Cosmetic profile designation only.", color: "#D93056" },
];

export function rewardIdForBranch(branch: MissionTwoBranchId | null): CosmeticRewardId | undefined { return branch === "last_platform" ? "civic_wayfinder" : branch === "static_trail" ? "relay_breaker" : undefined; }
export function normalizeInventory(stored: unknown): CosmeticRewardId[] { return Array.isArray(stored) ? stored.filter((id): id is CosmeticRewardId => id === "civic_wayfinder" || id === "relay_breaker") : []; }
export function normalizeEquippedCosmetics(stored: unknown, inventory: CosmeticRewardId[]): EquippedCosmetics {
  const candidate = stored && typeof stored === "object" ? stored as { title?: unknown; banner?: unknown } : {};
  const owned = new Set(inventory);
  const valid = (value: unknown): CosmeticRewardId | null => value === "civic_wayfinder" || value === "relay_breaker" ? owned.has(value) ? value : null : null;
  return { title: valid(candidate.title), banner: valid(candidate.banner) };
}
