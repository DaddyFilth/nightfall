export type MultiplayerModeId = "free_for_all" | "team_deathmatch" | "capture_the_flag";
export type MultiplayerMode = { id: MultiplayerModeId; name: string; shortName: string; teams: number; scoreLimit: number; durationSeconds: number; objective: string; unlock: string };

export const multiplayerModes: MultiplayerMode[] = [
  { id: "free_for_all", name: "Blood Hunt", shortName: "FFA", teams: 0, scoreLimit: 30, durationSeconds: 480, objective: "First hunter to 30 eliminations, or highest score at the eclipse bell.", unlock: "Available in the local rule simulation." },
  { id: "team_deathmatch", name: "Crimson Accord", shortName: "TDM", teams: 2, scoreLimit: 50, durationSeconds: 600, objective: "Two bloodlines race to 50 eliminations across contested territory.", unlock: "Rules contract ready; live transport requires host validation." },
  { id: "capture_the_flag", name: "Relic Run", shortName: "CTF", teams: 2, scoreLimit: 3, durationSeconds: 720, objective: "Secure the opposing eclipse relic and return it to your sanctuary.", unlock: "Rules contract ready; live transport requires host validation." },
];

export function modeById(id: MultiplayerModeId) { return multiplayerModes.find((mode) => mode.id === id) ?? multiplayerModes[0]; }

