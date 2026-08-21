export type AudioCueAccessibility = { id: string; label: string; subtitle: string; haptic: "light" | "medium" | "heavy" };

export const audioCueAccessibility: AudioCueAccessibility[] = [
  { id: "projectile_fire", label: "Projectile fire", subtitle: "THORNCOIL FIRED", haptic: "light" },
  { id: "impact_target", label: "Target impact", subtitle: "HIT CONFIRMED", haptic: "medium" },
  { id: "impact_solid", label: "Solid impact", subtitle: "SHOT BLOCKED", haptic: "light" },
  { id: "enemy_attack", label: "Hollowed attack", subtitle: "HOLLOWED STRIKES", haptic: "medium" },
  { id: "enemy_hit", label: "Hollowed hit", subtitle: "HOLLOWED STAGGERS", haptic: "light" },
  { id: "enemy_dissolve", label: "Hollowed dissolve", subtitle: "THREAT DISPERSED", haptic: "heavy" },
  { id: "cinematic_transition", label: "Cinematic transition", subtitle: "ARCHIVE TRANSITION", haptic: "medium" },
];

