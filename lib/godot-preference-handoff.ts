import type { MissionTwoBranchId } from "@/lib/blackout-protocol";
import type { GameSettings } from "@/lib/game-session";

export const GODOT_PREFERENCE_HANDOFF_SCHEMA = "nightfall.godot-preferences.v1";
export type GodotPreferenceHandoff = { schema: typeof GODOT_PREFERENCE_HANDOFF_SCHEMA; preferences: Pick<GameSettings, "sensitivity" | "reducedMotion" | "highContrastReticle" | "subtitles" | "colorMarkers" | "vibration" | "audioCueSubtitles" | "touchLayout" | "touchPrimaryAction">; campaign: { observatoryBranch: MissionTwoBranchId | null } };

export function buildGodotPreferenceHandoff(settings: GameSettings, observatoryBranch: MissionTwoBranchId | null): GodotPreferenceHandoff {
  return { schema: GODOT_PREFERENCE_HANDOFF_SCHEMA, preferences: { sensitivity: Math.max(20, Math.min(100, Math.round(settings.sensitivity))), reducedMotion: settings.reducedMotion, highContrastReticle: settings.highContrastReticle, subtitles: settings.subtitles, colorMarkers: settings.colorMarkers, vibration: settings.vibration, audioCueSubtitles: settings.audioCueSubtitles, touchLayout: settings.touchLayout, touchPrimaryAction: settings.touchPrimaryAction }, campaign: { observatoryBranch } };
}

export function isGodotPreferenceHandoff(value: unknown): value is GodotPreferenceHandoff {
  const payload = value as Partial<GodotPreferenceHandoff> | null;
  return Boolean(payload && payload.schema === GODOT_PREFERENCE_HANDOFF_SCHEMA && payload.preferences && typeof payload.preferences.sensitivity === "number" && (payload.campaign?.observatoryBranch === null || payload.campaign?.observatoryBranch === "last_platform" || payload.campaign?.observatoryBranch === "static_trail"));
}

