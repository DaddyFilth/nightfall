import { useEffect, useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import type { CombatResult } from "@/components/combat-arena";
import { ActionButton, Eyebrow, Panel, ProgressBar } from "@/components/nf-ui";
import { ashesBelowStages, nextCheckpoint } from "@/lib/ashes-below";
import { difficultyConfig, hunterFor, type Difficulty, type HunterId } from "@/lib/game-data";
import { haptic } from "@/lib/haptics";
import { cinematicForCheckpoint } from "@/lib/ashes-below-cinematics";
import { CheckpointCinematic } from "@/components/checkpoint-cinematic";

type BossPhase = 0 | 1 | 2;

export function AshesBelowMission({ hunterId, difficulty, startingCheckpoint, runId, onEnd, onExit, onCheckpoint }: { hunterId: HunterId; difficulty: Difficulty; startingCheckpoint: number; runId: number; onEnd: (result: CombatResult) => void; onExit: () => void; onCheckpoint: (checkpoint: number) => void }) {
  const hunter = hunterFor(hunterId);
  const [stageIndex, setStageIndex] = useState(startingCheckpoint);
  const [remaining, setRemaining] = useState(ashesBelowStages[startingCheckpoint]?.enemyGoal ?? 3);
  const [vitality, setVitality] = useState(100);
  const [bossHealth, setBossHealth] = useState(300);
  const [bossPhase, setBossPhase] = useState<BossPhase>(0);
  const [railReady, setRailReady] = useState(false);
  const [shards, setShards] = useState(0);
  const [shots, setShots] = useState(0);
  const [notice, setNotice] = useState("THE RAILS ARE LISTENING");
  const [paused, setPaused] = useState(false);
  const [ended, setEnded] = useState(false);
  const [cinematicCheckpoint, setCinematicCheckpoint] = useState<number | null>(startingCheckpoint);
  const stage = ashesBelowStages[Math.max(0, Math.min(stageIndex, ashesBelowStages.length - 1))];
  const config = difficultyConfig[difficulty];
  const isBoss = stage.kind === "boss";
  const progress = isBoss ? Math.round((1 - bossHealth / 300) * 100) : Math.round(((stage.enemyGoal - remaining) / Math.max(stage.enemyGoal, 1)) * 100);
  const totalScore = useMemo(() => shards + (isBoss ? Math.round((300 - bossHealth) / 25) : 0), [shards, isBoss, bossHealth]);

  useEffect(() => {
    const safeCheckpoint = Math.max(0, Math.min(startingCheckpoint, ashesBelowStages.length - 1));
    setStageIndex(safeCheckpoint); setRemaining(ashesBelowStages[safeCheckpoint].enemyGoal); setVitality(100); setBossHealth(300); setBossPhase(0); setRailReady(false); setShards(0); setShots(0); setPaused(false); setEnded(false); setCinematicCheckpoint(safeCheckpoint); setNotice(safeCheckpoint ? "CHECKPOINT RESTORED" : "THE RAILS ARE LISTENING");
  }, [runId, startingCheckpoint]);

  useEffect(() => {
    if (paused || ended || cinematicCheckpoint !== null) return;
    const damageTimer = setInterval(() => {
      const pressure = isBoss ? config.enemyHit + bossPhase * 3 : Math.max(3, config.enemyHit - 1);
      setVitality((current) => Math.max(0, current - pressure));
    }, isBoss ? 1800 : 2700);
    return () => clearInterval(damageTimer);
  }, [paused, ended, cinematicCheckpoint, isBoss, config.enemyHit, bossPhase]);

  useEffect(() => {
    if (!ended && vitality <= 0) {
      setEnded(true); haptic.heavy(); onEnd({ won: false, score: totalScore, shards, shots, title: "ASHES BELOW: SIGNAL LOST" });
    }
  }, [vitality, ended, onEnd, totalScore, shards, shots]);

  const moveToNextStage = () => {
    if (stageIndex >= ashesBelowStages.length - 1) return;
    const next = stageIndex + 1;
    if (stage.checkpointAfter) { onCheckpoint(nextCheckpoint(stageIndex)); setCinematicCheckpoint(next); setNotice("CHECKPOINT SECURED"); haptic.success(); }
    else { setNotice("DESCENDING DEEPER"); haptic.medium(); }
    setStageIndex(next); setRemaining(ashesBelowStages[next].enemyGoal); setVitality((current) => Math.min(100, current + 20));
  };

  const fire = () => {
    if (paused || ended) return;
    setShots((value) => value + 1);
    if (!isBoss) {
      const next = remaining - 1;
      setRemaining(next);
      setShards((value) => value + 1);
      if (next <= 0) { setNotice(stage.kind === "elite" ? "BLOOD WRAITH DISPERSED" : "SECTOR CLEARED"); setTimeout(moveToNextStage, 520); }
      else setNotice(stage.kind === "explore" ? "RELAY FRACTURED" : "HOLLOWED BANISHED");
      haptic.light();
      return;
    }

    if (bossPhase === 2 && !railReady) { setNotice("RAIL CONTROLS REQUIRED"); setVitality((current) => Math.max(0, current - 6)); haptic.heavy(); return; }
    const damage = bossPhase === 2 ? 50 : 28;
    const nextHealth = Math.max(0, bossHealth - damage);
    setBossHealth(nextHealth);
    if (nextHealth <= 200 && bossPhase === 0) { setBossPhase(1); setNotice("PHASE II — COVER COLLAPSE"); haptic.medium(); }
    else if (nextHealth <= 100 && bossPhase === 1) { setBossPhase(2); setNotice("PHASE III — RAIL CONTROL EXPOSED"); haptic.heavy(); }
    else if (nextHealth <= 0) { setEnded(true); onCheckpoint(0); haptic.success(); onEnd({ won: true, score: totalScore + 12, shards: shards + 4, shots: shots + 1, title: "ASHES BELOW: THE CONDUCTOR SILENCED" }); }
    else { setNotice(bossPhase === 2 ? "ENGINE WEAK POINT STRUCK" : "CONDUCTOR HIT"); haptic.light(); }
  };

  const useAbility = () => { if (paused || ended) return; setVitality((current) => Math.min(100, current + 14)); setNotice(`${hunter.tactical.split(" — ")[0].toUpperCase()} — VITALITY +14`); haptic.medium(); };
  const useRail = () => { if (!isBoss || bossPhase !== 2 || paused || ended) return; setRailReady(true); setNotice("BLOOD-POWERED RAILS ENGAGED"); haptic.heavy(); };
  const bossPhaseCopy = ["PHASE I · UV BLASTS / HOLLOWED SUMMONS", "PHASE II · TELEPORTS / COVER COLLAPSE", "PHASE III · ENGAGE RAIL CONTROLS"][bossPhase];
  const cinematic = cinematicCheckpoint === null ? undefined : cinematicForCheckpoint(cinematicCheckpoint);
  if (cinematic) return <View style={styles.shell}><CheckpointCinematic scene={cinematic} onContinue={() => setCinematicCheckpoint(null)} /></View>;

  return <View style={styles.shell}><View style={styles.header}><View><Eyebrow color="#D93056">The First Eclipse // Mission 01</Eyebrow><Text style={styles.missionTitle}>{stage.title}</Text><Text style={styles.location}>{stage.location}</Text></View><Pressable accessibilityRole="button" style={styles.pause} onPress={() => setPaused(true)}><Text style={styles.pauseText}>II</Text></Pressable></View><View style={styles.status}><View style={styles.statusItem}><Text style={styles.statusLabel}>VITALITY</Text><ProgressBar value={vitality} color={vitality > 35 ? "#D93056" : "#E7CB63"} /><Text style={styles.statusValue}>{vitality}%</Text></View><View style={styles.statusItem}><Text style={styles.statusLabel}>{isBoss ? "CONDUCTOR" : "OBJECTIVE"}</Text><ProgressBar value={progress} color={isBoss ? "#D93056" : "#3DE6E6"} /><Text style={styles.statusValue}>{isBoss ? `${bossHealth}/300` : `${stage.enemyGoal - remaining}/${stage.enemyGoal}`}</Text></View></View><View style={styles.chamber}><View style={styles.eclipse} /><View style={styles.railLeft} /><View style={styles.railRight} /><View style={styles.core}><Text style={styles.coreSymbol}>{isBoss ? "◉" : stage.kind === "elite" ? "✧" : "◇"}</Text><Text style={styles.coreLabel}>{isBoss ? "THE CONDUCTOR" : stage.kind === "elite" ? "BLOOD WRAITH" : "ECLIPSE NODE"}</Text></View><Text style={styles.notice}>{notice}</Text>{isBoss ? <View style={styles.phaseTag}><Text style={styles.phaseText}>{bossPhaseCopy}</Text></View> : <View style={styles.targetCount}><Text style={styles.targetValue}>{remaining}</Text><Text style={styles.targetLabel}>{stage.kind === "explore" ? "RELAYS REMAIN" : "THREATS REMAIN"}</Text></View>}</View><Panel style={styles.objective}><Eyebrow color="#3DE6E6">Objective</Eyebrow><Text style={styles.objectiveTitle}>{stage.objective}</Text><Text style={styles.objectiveCopy}>{stage.instruction}</Text>{stage.checkpointAfter ? <Text style={styles.checkpointNote}>NEXT SAVE POINT: SECURED ON COMPLETION</Text> : null}</Panel><View style={styles.controls}><Pressable accessibilityRole="button" style={styles.move}><Text style={styles.moveGlyph}>↗</Text><Text style={styles.moveText}>MOVE</Text></Pressable><View style={styles.controlStack}><View style={styles.utilityRow}><Pressable accessibilityRole="button" onPress={useAbility} style={styles.utility}><Text style={styles.utilityText}>VEIL</Text></Pressable>{isBoss && bossPhase === 2 ? <Pressable accessibilityRole="button" onPress={useRail} style={[styles.utility, railReady && styles.utilityActive]}><Text style={styles.utilityText}>{railReady ? "READY" : "RAIL"}</Text></Pressable> : <View style={styles.utilityGhost}><Text style={styles.utilityText}>DASH</Text></View>}</View><Pressable accessibilityRole="button" onPress={fire} style={styles.fire}><Text style={styles.fireText}>{isBoss ? "STRIKE" : "FIRE"}</Text><Text style={styles.fireSub}>{isBoss ? "THORNCOIL" : "CLEAR PATH"}</Text></Pressable></View></View>{paused ? <View style={styles.overlay}><View style={styles.pauseCard}><Eyebrow color="#3DE6E6">Checkpoint Protocol</Eyebrow><Text style={styles.pauseTitle}>THE ECLIPSE WAITS</Text><Text style={styles.pauseCopy}>Checkpoints are stored locally after the Maintenance Spine and Furnace Lift. The final boss resets to the latest secured checkpoint after defeat.</Text><ActionButton label="RESUME MISSION" onPress={() => setPaused(false)} /><ActionButton label="RETURN TO BRIEFING" tone="ghost" onPress={onExit} /></View></View> : null}</View>;
}

const styles = StyleSheet.create({ shell: { flex: 1, paddingHorizontal: 14, paddingTop: 10, paddingBottom: 12, backgroundColor: "#08070C", gap: 12 }, header: { flexDirection: "row", justifyContent: "space-between", alignItems: "flex-start" }, missionTitle: { color: "#F5F0E9", fontSize: 25, lineHeight: 30, fontWeight: "900" }, location: { color: "#A9A3B5", fontSize: 9, fontWeight: "900", letterSpacing: 0.8 }, pause: { width: 42, height: 42, borderRadius: 13, borderWidth: 1, borderColor: "#4D3B5D", alignItems: "center", justifyContent: "center", backgroundColor: "#17121F" }, pauseText: { color: "#F5F0E9", fontSize: 15, fontWeight: "900" }, status: { flexDirection: "row", gap: 10 }, statusItem: { flex: 1, gap: 4 }, statusLabel: { color: "#A9A3B5", fontSize: 9, fontWeight: "900", letterSpacing: 0.8 }, statusValue: { color: "#F5F0E9", fontSize: 12, fontWeight: "900" }, chamber: { flex: 1, minHeight: 260, overflow: "hidden", borderRadius: 26, borderWidth: 1, borderColor: "#49355D", backgroundColor: "#120D19", justifyContent: "center", alignItems: "center" }, eclipse: { position: "absolute", width: 240, height: 240, borderRadius: 120, borderWidth: 18, borderColor: "#4B2A67", opacity: 0.8 }, railLeft: { position: "absolute", left: -30, bottom: 65, width: 220, borderTopWidth: 5, borderColor: "#D93056", transform: [{ rotate: "-18deg" }] }, railRight: { position: "absolute", right: -30, bottom: 65, width: 220, borderTopWidth: 5, borderColor: "#3DE6E6", transform: [{ rotate: "18deg" }] }, core: { width: 150, height: 150, borderRadius: 75, borderWidth: 2, borderColor: "#8E5CFF", backgroundColor: "#21142C", alignItems: "center", justifyContent: "center", gap: 4 }, coreSymbol: { color: "#FF7F9D", fontSize: 55, lineHeight: 60 }, coreLabel: { color: "#F5F0E9", fontSize: 10, fontWeight: "900", letterSpacing: 0.6 }, notice: { position: "absolute", bottom: 15, color: "#F5F0E9", fontSize: 10, fontWeight: "900", letterSpacing: 0.8 }, phaseTag: { position: "absolute", top: 15, alignSelf: "center", paddingHorizontal: 10, paddingVertical: 6, borderRadius: 9, backgroundColor: "#3A1C31" }, phaseText: { color: "#FFB1C0", fontSize: 9, fontWeight: "900", letterSpacing: 0.5 }, targetCount: { position: "absolute", top: 14, right: 14, alignItems: "flex-end" }, targetValue: { color: "#3DE6E6", fontSize: 27, fontWeight: "900" }, targetLabel: { color: "#A9A3B5", fontSize: 8, fontWeight: "900", letterSpacing: 0.6 }, objective: { gap: 7 }, objectiveTitle: { color: "#F5F0E9", fontSize: 16, fontWeight: "900" }, objectiveCopy: { color: "#B9B1C4", fontSize: 12, lineHeight: 17 }, checkpointNote: { color: "#E7CB63", fontSize: 9, fontWeight: "900", letterSpacing: 0.5 }, controls: { height: 122, paddingHorizontal: 7, flexDirection: "row", justifyContent: "space-between", alignItems: "flex-end" }, move: { width: 86, height: 86, borderRadius: 43, borderWidth: 1, borderColor: "#504062", backgroundColor: "#1B1524", justifyContent: "center", alignItems: "center" }, moveGlyph: { color: "#3DE6E6", fontSize: 24, fontWeight: "900" }, moveText: { color: "#A9A3B5", fontSize: 9, fontWeight: "900", letterSpacing: 0.8 }, controlStack: { alignItems: "flex-end", gap: 7 }, utilityRow: { flexDirection: "row", gap: 8 }, utility: { width: 54, height: 34, borderRadius: 11, borderWidth: 1, borderColor: "#6A4B83", backgroundColor: "#21162C", alignItems: "center", justifyContent: "center" }, utilityGhost: { width: 54, height: 34, borderRadius: 11, borderWidth: 1, borderColor: "#443553", backgroundColor: "#17121F", alignItems: "center", justifyContent: "center" }, utilityActive: { backgroundColor: "#D93056", borderColor: "#FF9FB4" }, utilityText: { color: "#F5F0E9", fontSize: 9, fontWeight: "900", letterSpacing: 0.5 }, fire: { width: 104, height: 75, borderRadius: 38, borderWidth: 4, borderColor: "#FF9FB4", backgroundColor: "#D93056", alignItems: "center", justifyContent: "center" }, fireText: { color: "#FFF5F6", fontSize: 16, fontWeight: "900", letterSpacing: 0.7 }, fireSub: { color: "#FFF5F6", fontSize: 8, fontWeight: "800", marginTop: 2, opacity: 0.8 }, overlay: { position: "absolute", top: 0, bottom: 0, left: 0, right: 0, backgroundColor: "#08070CE8", justifyContent: "center", padding: 23 }, pauseCard: { backgroundColor: "#17121F", borderRadius: 24, borderWidth: 1, borderColor: "#593C72", padding: 20, gap: 12 }, pauseTitle: { color: "#F5F0E9", fontSize: 24, fontWeight: "900" }, pauseCopy: { color: "#B9B1C4", fontSize: 13, lineHeight: 19 } });
