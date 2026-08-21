export type MissionTwoBranchId = "last_platform" | "static_trail";
export type MissionTwoBranch = { id: MissionTwoBranchId; title: string; directive: string; risk: string; reward: string; color: string; scenes: { title: string; objective: string; context: string }[]; outcome: string };

export const blackoutProtocolBranches: MissionTwoBranch[] = [
  {
    id: "last_platform",
    title: "THE LAST PLATFORM",
    directive: "Divert the stranded night train before the eclipse timetable seals its doors.",
    risk: "The Conductor’s signal will reach the upper district unopposed.",
    reward: "The evacuees carry a forgotten station map and a human witness to the first relay.",
    color: "#3DE6E6",
    scenes: [
      { title: "Emergency Line", objective: "Restore the platform beacons", context: "Vesper locates a manual signal console, but its power is routed through three exposed relays." },
      { title: "Quiet Carriage", objective: "Hold the evacuation corridor", context: "The Hollowed have learned to imitate conductor calls. The player must separate the real passengers from the signal’s echoes." },
      { title: "Departure Window", objective: "Commit the diversion", context: "The train can leave only if the player burns the maintenance archive behind it. The evidence will be lost, but the people will not." },
    ],
    outcome: "Vesper’s map marks an unlisted service route into the Observatory. The bloodlines gain civilian trust, but the Conductor’s original timetable remains intact.",
  },
  {
    id: "static_trail",
    title: "FOLLOWING STATIC",
    directive: "Pursue the signal courier through the sealed service tunnels and recover the Conductor’s route cipher.",
    risk: "The last night train will remain trapped behind the upper-district gates.",
    reward: "The cipher reveals where the Conductor will expose its next relay core.",
    color: "#D93056",
    scenes: [
      { title: "Ghost Frequency", objective: "Trace the courier pulse", context: "Archivist Ora isolates a signature that is moving faster than any surviving train. It is carrying instructions, not blood." },
      { title: "Maintenance Dark", objective: "Choose the unlit route", context: "The player enters a flooded cable trench where ultraviolet sightlines are blind. Every step trades safety for signal proximity." },
      { title: "Cipher Theft", objective: "Break the courier shell", context: "The courier can be destroyed only after it finishes a transmission. The player may let it speak and learn the route, or strike early and save the train’s time." },
    ],
    outcome: "Ora decodes a weakness in the Observatory relay lattice. The next confrontation begins with tactical knowledge, but the upper district pays for the delay.",
  },
];

export function blackoutBranch(id: MissionTwoBranchId | null): MissionTwoBranch | undefined { return blackoutProtocolBranches.find((branch) => branch.id === id); }
export function clampMissionTwoStep(step: number): number { return Math.max(0, Math.min(Number.isFinite(step) ? Math.floor(step) : 0, 3)); }

