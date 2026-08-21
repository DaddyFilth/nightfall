import type { MissionTwoBranchId } from "@/lib/blackout-protocol";

export type ObservatoryReward = { branch: MissionTwoBranchId; title: string; cosmetic: string; mechanic: string; detail: string; color: string };

export const observatoryRewards: ObservatoryReward[] = [
  { branch: "last_platform", title: "CIVIC WAYFINDER", cosmetic: "Platform Keeper Banner", mechanic: "BEACON SANCTUARY", detail: "A local profile cosmetic honoring the evacuees’ service route. It carries no stat, combat, matchmaking, or progression advantage.", color: "#3DE6E6" },
  { branch: "static_trail", title: "RELAY BREAKER", cosmetic: "Cipher Halo Frame", mechanic: "THIRTEENTH PULSE", detail: "A local profile cosmetic honoring the stolen lattice cipher. It carries no stat, combat, matchmaking, or progression advantage.", color: "#D93056" },
];

export function observatoryReward(branch: MissionTwoBranchId | null): ObservatoryReward | undefined { return observatoryRewards.find((reward) => reward.branch === branch); }

