import type { MissionTwoBranchId } from "@/lib/blackout-protocol";

export type ObservatoryRoute = { branch: MissionTwoBranchId; origin: string; advantage: string; color: string; scenes: { title: string; objective: string; context: string }[]; resolution: string };

export const observatoryRoutes: ObservatoryRoute[] = [
  {
    branch: "last_platform",
    origin: "Vesper’s evacuees unfold the service map in a shelter beneath the north gate.",
    advantage: "CIVIC TRUST // The survivors unlock a silent service entrance that bypasses the outer patrol lattice.",
    color: "#3DE6E6",
    scenes: [
      { title: "Shelter Signal", objective: "Follow the witness route", context: "The map was not drawn for soldiers. It follows the maintenance corridors used by night-shift caretakers before the eclipse." },
      { title: "The Quiet Aperture", objective: "Protect the service entrance", context: "The Conductor’s patrol lattice cannot see the human route, but it can hear every forced door. The player must pass without turning the shelter into a target." },
      { title: "Observatory Floor", objective: "Secure the civilian relay", context: "The entrance becomes a future route for the city, provided the player can leave the first relay intact." },
    ],
    resolution: "The Observatory is breached through the service entrance. Nocturne retains a human route through the eclipse, and the next operation begins with a living map.",
  },
  {
    branch: "static_trail",
    origin: "Archivist Ora projects the stolen cipher across a blackout console in the upper district.",
    advantage: "LATTICE WEAKNESS // The courier cipher reveals a momentary gap in the Observatory’s ultraviolet defenses.",
    color: "#D93056",
    scenes: [
      { title: "Cipher Pulse", objective: "Decode the relay gap", context: "The Conductor repeats a twelve-beat defense pattern. The player must enter during the missing thirteenth pulse." },
      { title: "Red Window", objective: "Exploit the lattice weakness", context: "The route is exposed and short. Every second spent in the outer field increases the chance that the city notices the player’s signal." },
      { title: "Observatory Floor", objective: "Mark the core geometry", context: "The cipher makes the relay structure readable, allowing the next operation to target the core instead of breaking every defense around it." },
    ],
    resolution: "The Observatory is breached through the lattice gap. The bloodlines gain a precise tactical route, but the upper district remains under the eclipse’s pressure.",
  },
];

export function observatoryRoute(branch: MissionTwoBranchId | null): ObservatoryRoute | undefined { return observatoryRoutes.find((route) => route.branch === branch); }
export function clampObservatoryStep(step: number): number { return Math.max(0, Math.min(Number.isFinite(step) ? Math.floor(step) : 0, 3)); }

