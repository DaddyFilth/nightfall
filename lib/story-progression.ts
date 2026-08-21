export type StoryMissionId = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10;

export const STORY_MISSIONS = [
  { id: 1 as const, label: "ASHES BELOW", subtitle: "Brasswake Dockyards" },
  { id: 2 as const, label: "THE BROKEN COMPASS", subtitle: "Blackout Protocol" },
  { id: 3 as const, label: "THE OBSERVATORY", subtitle: "Drowned Admiral Convergence" },
  { id: 4 as const, label: "SABLE WAKE", subtitle: "Blackwater Pursuit" },
  { id: 5 as const, label: "LANTERNS OF THE LOST", subtitle: "Ghostlight Passage" },
  { id: 6 as const, label: "IRON CATHEDRAL", subtitle: "Brass Reliquary" },
  { id: 7 as const, label: "COFFIN FLEET", subtitle: "Moonless Armada" },
  { id: 8 as const, label: "THE THIRTEENTH BELL", subtitle: "Drowned Hour" },
  { id: 9 as const, label: "RED MERIDIAN", subtitle: "Bloodline Crossing" },
  { id: 10 as const, label: "BLOOD & BRASS", subtitle: "Final Tide" },
] as const;

export function normalizeStoryDefeatedThrough(value: unknown): number {
  const numeric = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(numeric)) return 0;
  return Math.max(0, Math.min(STORY_MISSIONS.length, Math.floor(numeric)));
}

export function isStoryMissionUnlocked(mission: StoryMissionId, defeatedThrough: number): boolean {
  return mission === 1 || mission <= normalizeStoryDefeatedThrough(defeatedThrough) + 1;
}

export function isStoryMissionDefeated(mission: StoryMissionId, defeatedThrough: number): boolean {
  return mission <= normalizeStoryDefeatedThrough(defeatedThrough);
}
