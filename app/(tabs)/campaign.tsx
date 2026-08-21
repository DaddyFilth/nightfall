import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system/legacy";
import * as Sharing from "expo-sharing";
import { useState } from "react";
import { ImageBackground, ScrollView, StyleSheet, Text, useWindowDimensions, View } from "react-native";
import { useRouter } from "expo-router";

import { ScreenContainer } from "@/components/screen-container";
import { ActionButton, Eyebrow, Panel, Pill, ProgressBar } from "@/components/nf-ui";
import { BrasswakeAtmosphere } from "@/components/brasswake-atmosphere";
import { AmbientSoundscape, useInterfaceSfx } from "@/components/local-soundscape";
import { ashesBelowCinematics } from "@/lib/ashes-below-cinematics";
import { pirateVisuals } from "@/lib/pirate-visuals";
import { useGame } from "@/lib/game-session";
import { STORY_MISSIONS, type StoryMissionId } from "@/lib/story-progression";
import { NATIVE_CAMPAIGN_COMPLETION_EXPORT_FILE, serializeNativeCampaignCompletion } from "@/lib/native-campaign-completion";

const MISSION_COLORS = ["#8D2634", "#B68A39", "#4A877A", "#5E79A6", "#E7CB63", "#8D2634", "#7A5C97", "#7F99A4", "#B24745", "#C7973A"];

export default function CampaignScreen() {
  const router = useRouter() as unknown as { push: (route: string) => void };
  const { width } = useWindowDimensions();
  const wide = width >= 700;
  const { difficulty, setDifficulty, prepareMatch, storyDefeatedThrough, canStartStoryMission, nativeCampaignCompletion, importNativeCampaignCompletion } = useGame();
  const { play } = useInterfaceSfx();
  const [importStatus, setImportStatus] = useState("IMPORT A LOCAL GODOT COMPLETION RECORD TO SYNC CAMPAIGN CARDS");
  const nextMission = STORY_MISSIONS.find((mission) => mission.id === storyDefeatedThrough + 1);

  const launch = () => { play("deploy"); prepareMatch("campaign"); router.push("/hunt"); };
  const launchMission = (mission: StoryMissionId) => {
    play("select");
    if (mission === 1) { launch(); return; }
    if (mission === 2) { router.push("/mission-two"); return; }
    if (mission === 3) { router.push("/observatory"); return; }
    router.push("/play-game");
  };
  const importNativeRecord = async () => {
    try {
      const selection = await DocumentPicker.getDocumentAsync({ type: "application/json", copyToCacheDirectory: true, multiple: false });
      if (selection.canceled) { setImportStatus("IMPORT CANCELLED // NO CAMPAIGN STATE CHANGED"); return; }
      const raw = await FileSystem.readAsStringAsync(selection.assets[0].uri, { encoding: FileSystem.EncodingType.UTF8 });
      const accepted = importNativeCampaignCompletion(JSON.parse(raw));
      setImportStatus(accepted ? "NATIVE RECORD APPLIED // CAMPAIGN CARDS UPDATED" : "RECORD REJECTED // EXPECTED BLOOD & BRASS LOCAL COMPLETION FILE");
    } catch {
      setImportStatus("IMPORT FAILED // SELECT THE EXPORTED campaign-completion.v1.json FILE");
    }
  };
  const exportNativeRecord = async () => {
    if (!nativeCampaignCompletion) { setImportStatus("NO NATIVE RECORD TO EXPORT // IMPORT OR COMPLETE A NATIVE MISSION FIRST"); return; }
    const directory = FileSystem.documentDirectory;
    if (!directory) { setImportStatus("LOCAL EXPORT UNAVAILABLE ON THIS PLATFORM"); return; }
    try {
      const uri = directory + NATIVE_CAMPAIGN_COMPLETION_EXPORT_FILE;
      await FileSystem.writeAsStringAsync(uri, serializeNativeCampaignCompletion(nativeCampaignCompletion), { encoding: FileSystem.EncodingType.UTF8 });
      if (!(await Sharing.isAvailableAsync())) { setImportStatus("RECORD SAVED LOCALLY // SYSTEM SHARING IS UNAVAILABLE HERE"); return; }
      await Sharing.shareAsync(uri, { mimeType: "application/json", dialogTitle: "Share Blood & Brass completion record" });
      setImportStatus("LOCAL COMPLETION RECORD EXPORTED // SHARE SHEET OPENED");
    } catch {
      setImportStatus("EXPORT FAILED // LOCAL CAMPAIGN STATE REMAINS SAFE");
    }
  };

  return <ScreenContainer edges={["top", "left", "right"]}><AmbientSoundscape scene="campaign" /><ScrollView contentContainerStyle={[styles.content, wide && styles.contentWide]} showsVerticalScrollIndicator={false}>
    <View style={[styles.headerDeck, wide && styles.headerDeckWide]}><View style={styles.headerCopy}><Eyebrow color="#8D2634">Campaign command // Local story</Eyebrow><Text style={styles.title}>THE DROWNED CHART</Text><Text style={styles.lead}>Advance through ten native first-person missions. Every level stays locked until the prior victory is recorded, whether locally in the companion or imported from the Godot campaign handoff.</Text><Text style={styles.currentObjective}>CURRENT OBJECTIVE // {nextMission ? `MISSION ${String(nextMission.id).padStart(2, "0")} · ${nextMission.label}` : "CAMPAIGN COMPLETE · REPLAY ANY CHAPTER"}</Text></View><Panel style={styles.progressDeck}><Eyebrow color="#C7973A">Story clearance</Eyebrow><Text style={styles.progressValue}>{storyDefeatedThrough} / {STORY_MISSIONS.length}</Text><Text style={styles.progressText}>MISSIONS DEFEATED</Text><ProgressBar value={Math.round((storyDefeatedThrough / STORY_MISSIONS.length) * 100)} color="#C7973A" /></Panel></View>
	    <ImageBackground source={pirateVisuals.dockyards} style={[styles.opening, wide && styles.openingWide]} imageStyle={styles.openingImage}><View style={styles.openingShade} /><BrasswakeAtmosphere /><View style={styles.openingText}><Eyebrow color="#C7973A">Brasswake transmission</Eyebrow><Text style={styles.quote}>“The tide carries a bell from the drowned fleet. Whatever answers it knows your blood.”</Text><Text style={styles.speaker}>— Vesper, harbor signal-runner</Text></View></ImageBackground>
	    <Panel style={styles.importPanel}><Eyebrow color="#4A877A">Native campaign handoff</Eyebrow><Text style={styles.panelTitle}>SYNC / EXPORT LOCAL COMPLETION</Text><Text style={styles.copy}>{importStatus}</Text>{nativeCampaignCompletion ? <Text style={styles.nativeRecord}>LAST NATIVE VICTORY // {nativeCampaignCompletion.completedTitle} // LEVEL {String(nativeCampaignCompletion.completedMission).padStart(2, "0")}</Text> : null}<ActionButton compact label="IMPORT NATIVE COMPLETION" detail="SELECT campaign-completion.v1.json" tone="cyan" onPress={importNativeRecord} /><ActionButton compact label="EXPORT / SHARE COMPLETION" detail="SAVE LOCAL JSON + OPEN SYSTEM SHARE" tone="violet" disabled={!nativeCampaignCompletion} onPress={exportNativeRecord} /></Panel>
    <View style={styles.missionBoard}>{STORY_MISSIONS.map((mission, index) => {
      const unlocked = canStartStoryMission(mission.id);
      const defeated = mission.id <= storyDefeatedThrough;
      const nativeDefeated = Boolean(nativeCampaignCompletion && mission.id <= nativeCampaignCompletion.defeatedThrough);
      const detail = defeated ? "Mission cleared. Replay the native FPS encounter from the Drowned Chart hub." : unlocked ? "Native FPS mission ready. Solve checkpoint routes, use environmental objects, and defeat the named boss." : `Defeat Mission ${String(mission.id - 1).padStart(2, "0")} to unlock this route.`;
      const action = defeated ? "REPLAY NATIVE MISSION" : unlocked ? "DEPLOY NATIVE MISSION" : `MISSION ${String(mission.id - 1).padStart(2, "0")} REQUIRED`;
      return <MissionCard key={mission.id} number={String(mission.id).padStart(2, "0")} eyebrow={defeated ? "Defeated" : unlocked ? "Native route ready" : "Locked route"} title={mission.label} detail={detail} tipTitle={nativeDefeated ? "NATIVE COMPLETION VERIFIED" : unlocked ? "CHECKPOINT DIRECTIVE" : "UNLOCK CONDITION"} tip={nativeDefeated ? "This card reflects a validated local Godot completion record." : unlocked ? "Find the correct environmental route, clear the checkpoint gate, then continue toward the mission boss." : "Only a completed preceding mission opens this card."} accent={MISSION_COLORS[index]} action={action} actionDetail={nativeDefeated ? "LOCAL GODOT RECORD" : `${mission.subtitle.toUpperCase()} // FIRST-PERSON CAMPAIGN`} locked={!unlocked} defeated={defeated} onPress={() => launchMission(mission.id)} />;
    })}</View>
    <View style={[styles.lowerBoard, wide && styles.lowerBoardWide]}><Panel style={styles.timelinePanel}><Eyebrow color="#8D2634">Black tide archive</Eyebrow><Text style={styles.sectionTitle}>A LOGBOOK BELOW THE WAVES</Text><View style={styles.timeline}>{ashesBelowCinematics.map((event) => <TimelineEvent key={event.checkpoint} timestamp={event.timestamp} headline={event.headline} context={event.context} color={event.color} />)}</View></Panel><Panel style={styles.difficultyPanel}><Eyebrow color="#C7973A">Pressure level</Eyebrow><Text style={styles.sectionTitle}>SELECT DIFFICULTY</Text><Text style={styles.copy}>Difficulty changes local encounter pressure, not checkpoint logic, campaign order, or cosmetic outcome.</Text><View style={styles.difficulties}>{(["Initiate", "Nightmare", "Eclipse"] as const).map((item) => <Pill key={item} label={item} active={difficulty === item} color="#B68A39" onPress={() => { play("select"); setDifficulty(item); }} />)}</View><ActionButton label="OPEN NATIVE CAMPAIGN" detail="LANDSCAPE GODOT FPS HANDOFF" tone="cyan" onPress={() => { play("select"); router.push("/play-game"); }} /></Panel></View>
  </ScrollView></ScreenContainer>;
}

function MissionCard({ number, eyebrow, title, detail, tipTitle, tip, accent, action, actionDetail, locked = false, defeated = false, onPress }: { number: string; eyebrow: string; title: string; detail: string; tipTitle: string; tip: string; accent: string; action: string; actionDetail: string; locked?: boolean; defeated?: boolean; onPress: () => void }) { return <Panel style={{ ...styles.missionCard, borderTopColor: accent, opacity: locked ? 0.62 : 1 }}><Text style={[styles.missionNumber, { color: accent }]}>{number}</Text><Eyebrow color={locked ? "#82755F" : accent}>{eyebrow}</Eyebrow><Text style={styles.missionTitle}>{title}</Text><Text style={styles.copy}>{detail}</Text><View style={[styles.missionTip, { borderLeftColor: accent }]}><Text style={[styles.missionTipTitle, { color: accent }]}>{tipTitle}</Text><Text style={styles.missionTipCopy}>{tip}</Text></View><ActionButton compact label={action} detail={defeated ? "MISSION DEFEATED // " + actionDetail : actionDetail} tone={number === "01" ? "crimson" : number === "02" ? "violet" : "cyan"} disabled={locked} onPress={onPress} /></Panel>; }
function TimelineEvent({ timestamp, headline, context, color }: { timestamp: string; headline: string; context: string; color: string }) { return <View style={[styles.timelineItem, { borderLeftColor: color }]}><Text style={[styles.timelineTime, { color }]}>{timestamp}</Text><Text style={styles.timelineHeadline}>{headline}</Text><Text style={styles.timelineContext}>{context}</Text></View>; }

const styles = StyleSheet.create({ content: { padding: 16, paddingBottom: 28, gap: 13 }, contentWide: { paddingHorizontal: 24, paddingTop: 14, maxWidth: 1440, alignSelf: "center", width: "100%" }, headerDeck: { gap: 11 }, headerDeckWide: { flexDirection: "row", alignItems: "stretch" }, headerCopy: { flex: 1, gap: 4 }, title: { color: "#EDE1C4", fontSize: 30, lineHeight: 35, fontWeight: "900", letterSpacing: 0.8 }, lead: { color: "#B9AF9A", fontSize: 12, lineHeight: 18, maxWidth: 680 }, currentObjective: { color: "#C7973A", fontSize: 9, lineHeight: 13, fontWeight: "900", letterSpacing: 0.55, marginTop: 3 }, progressDeck: { minWidth: 270, justifyContent: "center", borderLeftWidth: 3, borderLeftColor: "#C7973A" }, progressValue: { color: "#EDE1C4", fontSize: 27, lineHeight: 31, fontWeight: "900" }, progressText: { color: "#A89D86", fontSize: 8, fontWeight: "900", letterSpacing: 0.8 }, opening: { height: 208, overflow: "hidden", borderRadius: 16, justifyContent: "flex-end", borderWidth: 1, borderColor: "#70532B", backgroundColor: "#211A15" }, openingWide: { height: 230 }, openingImage: { opacity: 0.8 }, openingShade: { ...StyleSheet.absoluteFillObject, backgroundColor: "#080604A8" }, openingText: { padding: 16, gap: 5, maxWidth: 670 }, quote: { color: "#F6E8CF", fontSize: 14, lineHeight: 20, fontWeight: "700" }, speaker: { color: "#C3B596", fontSize: 10, fontWeight: "800" }, importPanel: { gap: 8, borderLeftWidth: 3, borderLeftColor: "#4A877A" }, panelTitle: { color: "#EDE1C4", fontSize: 17, lineHeight: 22, fontWeight: "900" }, nativeRecord: { color: "#E7CB63", fontSize: 10, lineHeight: 14, fontWeight: "900", letterSpacing: 0.45 }, missionBoard: { gap: 10 }, missionCard: { minHeight: 224, gap: 8, borderTopWidth: 3, position: "relative" }, missionNumber: { position: "absolute", top: 14, right: 15, fontSize: 30, fontWeight: "900", opacity: 0.45 }, missionTitle: { color: "#EDE1C4", fontSize: 17, lineHeight: 22, fontWeight: "900", paddingRight: 38 }, copy: { color: "#B9AF9A", fontSize: 12, lineHeight: 18, flex: 1 }, missionTip: { gap: 2, borderLeftWidth: 3, paddingLeft: 8, paddingVertical: 2 }, missionTipTitle: { fontSize: 8, fontWeight: "900", letterSpacing: 0.65 }, missionTipCopy: { color: "#D7CABB", fontSize: 9, lineHeight: 13 }, lowerBoard: { gap: 10 }, lowerBoardWide: { flexDirection: "row", alignItems: "stretch" }, timelinePanel: { flex: 1.2, gap: 9 }, difficultyPanel: { flex: 0.8, gap: 10, borderTopWidth: 2, borderTopColor: "#C7973A" }, sectionTitle: { color: "#EDE1C4", fontSize: 15, lineHeight: 20, fontWeight: "900" }, timeline: { gap: 9 }, timelineItem: { borderLeftWidth: 3, paddingLeft: 10, gap: 2 }, timelineTime: { fontSize: 8, fontWeight: "900", letterSpacing: 0.7 }, timelineHeadline: { color: "#EDE1C4", fontSize: 12, lineHeight: 16, fontWeight: "900" }, timelineContext: { color: "#B9AF9A", fontSize: 10, lineHeight: 14 }, difficulties: { flexDirection: "row", flexWrap: "wrap", gap: 8 } });
