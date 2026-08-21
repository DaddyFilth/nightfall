import AsyncStorage from "@react-native-async-storage/async-storage";
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type PropsWithChildren } from "react";

import type { Difficulty, HunterId, MatchIntent } from "@/lib/game-data";
import type { MultiplayerModeId } from "@/lib/multiplayer-modes";
import type { MissionTwoBranchId } from "@/lib/blackout-protocol";
import { rewardIdForBranch, normalizeEquippedCosmetics, normalizeInventory, type CosmeticRewardId, type EquippedCosmetics } from "./cosmetic-inventory";
import { isStoryMissionUnlocked, normalizeStoryDefeatedThrough, type StoryMissionId } from "./story-progression";
import { nextTacticalTutorialStep, shouldShowTacticalTutorial, TACTICAL_TUTORIAL_KEY } from "./tactical-tutorial";
import { mergeNativeCampaignCompletion, parseNativeCampaignCompletion, type NativeCampaignCompletion } from "./native-campaign-completion";

export type TouchLayout = "right_handed" | "left_handed";
export type TouchPrimaryAction = "fire" | "veil" | "dash";
export type GameSettings = { sensitivity: number; reducedMotion: boolean; highContrastReticle: boolean; subtitles: boolean; colorMarkers: boolean; vibration: boolean; audioCueSubtitles: boolean; ambientMusic: boolean; interfaceSounds: boolean; musicVolume: number; touchLayout: TouchLayout; touchPrimaryAction: TouchPrimaryAction };
type GameSession = { selectedHunter: HunterId; setSelectedHunter: (hunter: HunterId) => void; selectedArena: string; setSelectedArena: (arena: string) => void; selectedMode: MultiplayerModeId; setSelectedMode: (mode: MultiplayerModeId) => void; difficulty: Difficulty; setDifficulty: (difficulty: Difficulty) => void; matchIntent: MatchIntent; prepareMatch: (intent: MatchIntent) => void; clearance: number; recordCompletion: () => void; missionCheckpoint: number; saveMissionCheckpoint: (checkpoint: number) => void; storyDefeatedThrough: number; canStartStoryMission: (mission: StoryMissionId) => boolean; recordStoryMissionDefeat: (mission: StoryMissionId) => void; nativeCampaignCompletion: NativeCampaignCompletion | null; importNativeCampaignCompletion: (record: unknown) => boolean; missionTwoBranch: MissionTwoBranchId | null; missionTwoStep: number; chooseMissionTwoBranch: (branch: MissionTwoBranchId) => void; advanceMissionTwoStep: () => void; observatoryStep: number; advanceObservatoryStep: () => void; inventory: CosmeticRewardId[]; equippedCosmetics: EquippedCosmetics; equipTitle: (reward: CosmeticRewardId) => void; equipBanner: (reward: CosmeticRewardId) => void; settings: GameSettings; updateSettings: (patch: Partial<GameSettings>) => void; tutorialStep: number | null; advanceTacticalTutorial: () => void; dismissTacticalTutorial: () => void; replayTacticalTutorial: () => void; hydrated: boolean };
const SETTINGS_KEY = "nightfall.settings.v1";
const CHECKPOINT_KEY = "nightfall.ashes_below.checkpoint.v1";
const MODE_KEY = "nightfall.multiplayer.mode.v1";
const MISSION_TWO_KEY = "nightfall.blackout_protocol.v1";
const OBSERVATORY_KEY = "nightfall.observatory.v1";
const STORY_PROGRESS_KEY = "nightfall.story_progress.v1";
const NATIVE_CAMPAIGN_COMPLETION_KEY = "nightfall.native_campaign_completion.v1";
const INVENTORY_KEY = "nightfall.cosmetic_inventory.v1";
const EQUIPPED_COSMETICS_KEY = "nightfall.equipped_cosmetics.v1";
export const defaultSettings: GameSettings = { sensitivity: 65, reducedMotion: false, highContrastReticle: false, subtitles: true, colorMarkers: true, vibration: true, audioCueSubtitles: true, ambientMusic: true, interfaceSounds: true, musicVolume: 34, touchLayout: "right_handed", touchPrimaryAction: "fire" };
export function mergeSettings(stored: Partial<GameSettings> | null | undefined): GameSettings { return { ...defaultSettings, ...stored }; }
const GameContext = createContext<GameSession | null>(null);

export function GameProvider({ children }: PropsWithChildren) {
  const [selectedHunter, setSelectedHunter] = useState<HunterId>("duskstalker");
  const [selectedArena, setSelectedArena] = useState("Cathedral of Static");
  const [selectedMode, setSelectedMode] = useState<MultiplayerModeId>("free_for_all");
  const [difficulty, setDifficulty] = useState<Difficulty>("Initiate");
  const [matchIntent, setMatchIntent] = useState<MatchIntent>("blood_hunt");
  const [clearance, setClearance] = useState(4);
  const [missionCheckpoint, setMissionCheckpoint] = useState(0);
	const [storyDefeatedThrough, setStoryDefeatedThrough] = useState(0);
	const [nativeCampaignCompletion, setNativeCampaignCompletion] = useState<NativeCampaignCompletion | null>(null);
  const [missionTwoBranch, setMissionTwoBranch] = useState<MissionTwoBranchId | null>(null);
  const [missionTwoStep, setMissionTwoStep] = useState(0);
  const [observatoryStep, setObservatoryStep] = useState(0);
  const [inventory, setInventory] = useState<CosmeticRewardId[]>([]);
  const [equippedCosmetics, setEquippedCosmetics] = useState<EquippedCosmetics>({ title: null, banner: null });
  const [settings, setSettings] = useState<GameSettings>(defaultSettings);
  const [tutorialStep, setTutorialStep] = useState<number | null>(null);
  const [hydrated, setHydrated] = useState(false);

	useEffect(() => { Promise.all([AsyncStorage.getItem(SETTINGS_KEY), AsyncStorage.getItem(CHECKPOINT_KEY), AsyncStorage.getItem(MODE_KEY), AsyncStorage.getItem(MISSION_TWO_KEY), AsyncStorage.getItem(OBSERVATORY_KEY), AsyncStorage.getItem(STORY_PROGRESS_KEY), AsyncStorage.getItem(NATIVE_CAMPAIGN_COMPLETION_KEY), AsyncStorage.getItem(INVENTORY_KEY), AsyncStorage.getItem(EQUIPPED_COSMETICS_KEY), AsyncStorage.getItem(TACTICAL_TUTORIAL_KEY)]).then(([settingsValue, checkpointValue, modeValue, missionTwoValue, observatoryValue, storyProgressValue, nativeCompletionValue, inventoryValue, equippedValue, tutorialValue]) => { if (settingsValue) setSettings(mergeSettings(JSON.parse(settingsValue))); if (checkpointValue) setMissionCheckpoint(Math.max(0, Math.min(Number(checkpointValue) || 0, 3))); if (modeValue === "free_for_all" || modeValue === "team_deathmatch" || modeValue === "capture_the_flag") setSelectedMode(modeValue); if (missionTwoValue) { const parsed = JSON.parse(missionTwoValue); if (parsed?.branch === "last_platform" || parsed?.branch === "static_trail") setMissionTwoBranch(parsed.branch); if (Number.isFinite(parsed?.step)) setMissionTwoStep(Math.max(0, Math.min(Math.floor(parsed.step), 3))); } if (observatoryValue) setObservatoryStep(Math.max(0, Math.min(Number(observatoryValue) || 0, 3))); const nativeRecord = nativeCompletionValue ? parseNativeCampaignCompletion(JSON.parse(nativeCompletionValue)) : null; if (nativeRecord) setNativeCampaignCompletion(nativeRecord); const storedProgress = storyProgressValue ? normalizeStoryDefeatedThrough(storyProgressValue) : 0; setStoryDefeatedThrough(nativeRecord ? mergeNativeCampaignCompletion(storedProgress, nativeRecord) : storedProgress); const restoredInventory = inventoryValue ? normalizeInventory(JSON.parse(inventoryValue)) : []; setInventory(restoredInventory); setEquippedCosmetics(normalizeEquippedCosmetics(equippedValue ? JSON.parse(equippedValue) : null, restoredInventory)); if (shouldShowTacticalTutorial(tutorialValue)) setTutorialStep(0); }).finally(() => setHydrated(true)); }, []);
  const updateSettings = useCallback((patch: Partial<GameSettings>) => { setSettings((current) => { const next = { ...current, ...patch }; AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(next)).catch(() => undefined); return next; }); }, []);
  const saveMissionCheckpoint = useCallback((checkpoint: number) => { const safe = Math.max(0, Math.min(checkpoint, 3)); setMissionCheckpoint(safe); AsyncStorage.setItem(CHECKPOINT_KEY, String(safe)).catch(() => undefined); }, []);
	const recordStoryMissionDefeat = useCallback((mission: StoryMissionId) => { setStoryDefeatedThrough((current) => { if (!isStoryMissionUnlocked(mission, current)) return current; const next = Math.max(current, mission); AsyncStorage.setItem(STORY_PROGRESS_KEY, String(next)).catch(() => undefined); return next; }); }, []);
	const importNativeCampaignCompletion = useCallback((record: unknown) => { const parsed = parseNativeCampaignCompletion(record); if (!parsed) return false; setNativeCampaignCompletion(parsed); setStoryDefeatedThrough((current) => { const next = mergeNativeCampaignCompletion(current, parsed); AsyncStorage.setItem(STORY_PROGRESS_KEY, String(next)).catch(() => undefined); return next; }); AsyncStorage.setItem(NATIVE_CAMPAIGN_COMPLETION_KEY, JSON.stringify(parsed)).catch(() => undefined); return true; }, []);
  const chooseMode = useCallback((mode: MultiplayerModeId) => { setSelectedMode(mode); AsyncStorage.setItem(MODE_KEY, mode).catch(() => undefined); }, []);
  const chooseMissionTwoBranch = useCallback((branch: MissionTwoBranchId) => { setMissionTwoBranch(branch); setMissionTwoStep(0); AsyncStorage.setItem(MISSION_TWO_KEY, JSON.stringify({ branch, step: 0 })).catch(() => undefined); }, []);
  const advanceMissionTwoStep = useCallback(() => { setMissionTwoStep((current) => { const next = Math.min(current + 1, 3); AsyncStorage.setItem(MISSION_TWO_KEY, JSON.stringify({ branch: missionTwoBranch, step: next })).catch(() => undefined); if (next === 3) recordStoryMissionDefeat(2); return next; }); }, [missionTwoBranch, recordStoryMissionDefeat]);
  const advanceObservatoryStep = useCallback(() => { setObservatoryStep((current) => { const next = Math.min(current + 1, 3); AsyncStorage.setItem(OBSERVATORY_KEY, String(next)).catch(() => undefined); if (next === 3) { recordStoryMissionDefeat(3); const reward = rewardIdForBranch(missionTwoBranch); if (reward) setInventory((currentInventory) => { const nextInventory = currentInventory.includes(reward) ? currentInventory : [...currentInventory, reward]; AsyncStorage.setItem(INVENTORY_KEY, JSON.stringify(nextInventory)).catch(() => undefined); return nextInventory; }); } return next; }); }, [missionTwoBranch, recordStoryMissionDefeat]);
  const equip = useCallback((slot: keyof EquippedCosmetics, reward: CosmeticRewardId) => { if (!inventory.includes(reward)) return; setEquippedCosmetics((current) => { const next = { ...current, [slot]: reward }; AsyncStorage.setItem(EQUIPPED_COSMETICS_KEY, JSON.stringify(next)).catch(() => undefined); return next; }); }, [inventory]);
  const dismissTacticalTutorial = useCallback(() => { setTutorialStep(null); AsyncStorage.setItem(TACTICAL_TUTORIAL_KEY, "completed").catch(() => undefined); }, []);
  const advanceTacticalTutorial = useCallback(() => { setTutorialStep((current) => { if (current === null) return null; const next = nextTacticalTutorialStep(current); if (next === null) AsyncStorage.setItem(TACTICAL_TUTORIAL_KEY, "completed").catch(() => undefined); return next; }); }, []);
  const replayTacticalTutorial = useCallback(() => { setTutorialStep(0); AsyncStorage.setItem(TACTICAL_TUTORIAL_KEY, "in_progress").catch(() => undefined); }, []);
	const value = useMemo(() => ({ selectedHunter, setSelectedHunter, selectedArena, setSelectedArena, selectedMode, setSelectedMode: chooseMode, difficulty, setDifficulty, matchIntent, prepareMatch: setMatchIntent, clearance, recordCompletion: () => setClearance((value) => value + 1), missionCheckpoint, saveMissionCheckpoint, storyDefeatedThrough, canStartStoryMission: (mission: StoryMissionId) => isStoryMissionUnlocked(mission, storyDefeatedThrough), recordStoryMissionDefeat, nativeCampaignCompletion, importNativeCampaignCompletion, missionTwoBranch, missionTwoStep, chooseMissionTwoBranch, advanceMissionTwoStep, observatoryStep, advanceObservatoryStep, inventory, equippedCosmetics, equipTitle: (reward: CosmeticRewardId) => equip("title", reward), equipBanner: (reward: CosmeticRewardId) => equip("banner", reward), settings, updateSettings, tutorialStep, advanceTacticalTutorial, dismissTacticalTutorial, replayTacticalTutorial, hydrated }), [selectedHunter, selectedArena, selectedMode, chooseMode, difficulty, matchIntent, clearance, missionCheckpoint, saveMissionCheckpoint, storyDefeatedThrough, recordStoryMissionDefeat, nativeCampaignCompletion, importNativeCampaignCompletion, missionTwoBranch, missionTwoStep, chooseMissionTwoBranch, advanceMissionTwoStep, observatoryStep, advanceObservatoryStep, inventory, equippedCosmetics, equip, settings, updateSettings, tutorialStep, advanceTacticalTutorial, dismissTacticalTutorial, replayTacticalTutorial, hydrated]);
  return <GameContext.Provider value={value}>{children}</GameContext.Provider>;
}

export function useGame() { const context = useContext(GameContext); if (!context) throw new Error("useGame must be used within GameProvider"); return context; }
