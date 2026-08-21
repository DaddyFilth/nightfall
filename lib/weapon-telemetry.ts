import type { Weapon } from "@/lib/game-data";

export type CombatStat = { label: string; value: number; fieldNote: string };
export type WeaponTelemetry = { accent: string; profile: string; stats: CombatStat[] };

const telemetry: Record<Weapon["name"], WeaponTelemetry> = {
  "Brasswake Wheel-Lock": { accent: "#C7973A", profile: "BALANCED DUELIST PROFILE", stats: [{ label: "HANDLING", value: 78, fieldNote: "A quick-ready profile for sidearm transitions and controlled bursts." }, { label: "REACH", value: 58, fieldNote: "Designed for deck lanes, not distant rigging shots." }, { label: "IMPACT", value: 61, fieldNote: "Reliable three-round pressure with no hidden damage bonus." }] },
  "Galleon Repeater": { accent: "#4A877A", profile: "CORRIDOR SUPPRESSION PROFILE", stats: [{ label: "HANDLING", value: 72, fieldNote: "Stable recoil rhythm supports movement through tight deck routes." }, { label: "REACH", value: 44, fieldNote: "Its effective presentation band stays close to the boarding line." }, { label: "TEMPO", value: 88, fieldNote: "Fast automatic cadence trades deliberate precision for pressure." }] },
  "Catacomb Blunderbuss": { accent: "#8D2634", profile: "BOARDING IMPACT PROFILE", stats: [{ label: "HANDLING", value: 49, fieldNote: "A slower reset keeps its boarding impact readable and measured." }, { label: "REACH", value: 28, fieldNote: "Built for close quarters rather than long dockyard lanes." }, { label: "IMPACT", value: 94, fieldNote: "High point-blank presentation impact; it does not unlock paid power." }] },
  "Astral Harpoon": { accent: "#8E5CFF", profile: "PRECISION ANCHOR PROFILE", stats: [{ label: "HANDLING", value: 57, fieldNote: "Requires deliberate aim alignment before a shot is committed." }, { label: "REACH", value: 91, fieldNote: "The strongest line-of-sight profile in the local weapon dossier." }, { label: "IMPACT", value: 76, fieldNote: "A focused single-shot presentation profile rewards patience." }] },
  "Bloodwake Cutlass": { accent: "#D93056", profile: "CLOSE-PRESSURE PROFILE", stats: [{ label: "HANDLING", value: 92, fieldNote: "Fast ready time supports the Captain’s readable cutlass transition." }, { label: "REACH", value: 16, fieldNote: "This is a boarding-range tool with intentionally limited distance." }, { label: "MOBILITY", value: 83, fieldNote: "Lunge-oriented presentation supports close pressure without stat boosts." }] },
};

export function weaponTelemetryFor(name: Weapon["name"]): WeaponTelemetry {
  return telemetry[name];
}
