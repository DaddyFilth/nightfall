export type AshesBelowStageKind = "explore" | "encounter" | "elite" | "boss";
export type AshesBelowStage = {
  id: string;
  title: string;
  location: string;
  kind: AshesBelowStageKind;
  objective: string;
  instruction: string;
  enemyGoal: number;
  checkpointAfter: boolean;
};

export const ashesBelowStages: AshesBelowStage[] = [
  { id: "signal-platform", title: "Signal Platform", location: "ABANDONED RAIL STATION", kind: "explore", objective: "Stabilize the blood-signal relay", instruction: "Destroy three eclipse relays before the patrol converges.", enemyGoal: 3, checkpointAfter: false },
  { id: "maintenance-spine", title: "Maintenance Spine", location: "SERVICE TUNNELS", kind: "encounter", objective: "Break the Hollowed cordon", instruction: "Banish the approaching Hollowed before the line becomes overrun.", enemyGoal: 5, checkpointAfter: true },
  { id: "furnace-lift", title: "Furnace Lift", location: "ECLIPSE FOUNDRY ACCESS", kind: "elite", objective: "Defeat the Blood Wraith", instruction: "Use Veil Step to suppress ultraviolet focus fire and disperse the elite.", enemyGoal: 1, checkpointAfter: true },
  { id: "conductor-core", title: "The Conductor", location: "ECLIPSE ENGINE CORE", kind: "boss", objective: "Expose the engine’s final weak point", instruction: "Survive the Conductor’s phases and use the blood-powered rail controls.", enemyGoal: 0, checkpointAfter: false },
];

export function stageAt(checkpoint: number): AshesBelowStage {
  return ashesBelowStages[Math.max(0, Math.min(checkpoint, ashesBelowStages.length - 1))];
}

export function nextCheckpoint(completedStageIndex: number): number {
  return Math.max(0, Math.min(completedStageIndex + 1, ashesBelowStages.length - 1));
}

