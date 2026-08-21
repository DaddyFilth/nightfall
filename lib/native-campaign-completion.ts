import { normalizeStoryDefeatedThrough, type StoryMissionId } from "./story-progression";

export const NATIVE_CAMPAIGN_COMPLETION_SCHEMA = "blood-brass.campaign-completion.v1";
export const NATIVE_CAMPAIGN_COMPLETION_EXPORT_FILE = "blood-and-brass-campaign-completion.v1.json";

export type NativeCampaignCompletion = {
  schema: typeof NATIVE_CAMPAIGN_COMPLETION_SCHEMA;
  completedMission: StoryMissionId;
  defeatedThrough: number;
  completedTitle: string;
  recordedAtUnix: number;
};

export function parseNativeCampaignCompletion(value: unknown): NativeCampaignCompletion | null {
  const payload = value as Partial<NativeCampaignCompletion> | null;
  if (!payload || payload.schema !== NATIVE_CAMPAIGN_COMPLETION_SCHEMA) return null;
  const completedMission = normalizeStoryDefeatedThrough(payload.completedMission);
  const defeatedThrough = normalizeStoryDefeatedThrough(payload.defeatedThrough);
  const recordedAtUnix = payload.recordedAtUnix;
  if (completedMission < 1 || completedMission > 10 || defeatedThrough < completedMission || typeof payload.completedTitle !== "string" || payload.completedTitle.length === 0 || typeof recordedAtUnix !== "number" || !Number.isFinite(recordedAtUnix)) return null;
  return { schema: NATIVE_CAMPAIGN_COMPLETION_SCHEMA, completedMission: completedMission as StoryMissionId, defeatedThrough, completedTitle: payload.completedTitle, recordedAtUnix: Math.max(0, Math.floor(recordedAtUnix)) };
}

export function mergeNativeCampaignCompletion(currentDefeatedThrough: number, record: NativeCampaignCompletion): number {
  return Math.max(normalizeStoryDefeatedThrough(currentDefeatedThrough), record.defeatedThrough);
}

export function serializeNativeCampaignCompletion(record: NativeCampaignCompletion): string {
  return JSON.stringify(record, null, 2);
}
