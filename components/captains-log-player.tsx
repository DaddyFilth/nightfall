import { useEffect, useMemo } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { setAudioModeAsync, useAudioPlayer, useAudioPlayerStatus } from "expo-audio";
import { useGame } from "@/lib/game-session";
import type { CaptainLogEntry } from "@/lib/captains-log";
import { useResourcePacks } from "@/lib/resource-packs";

const audioAssetIds = { 0: "arrival", 2: "descent", 3: "admiral" } as const;

export function CaptainsLogPlayer({ entry }: { entry: CaptainLogEntry }) {
  const { assetUriFor } = useResourcePacks();
  const source = assetUriFor("cinematic_audio", audioAssetIds[entry.checkpoint as keyof typeof audioAssetIds]);
  if (!source) return <View style={styles.shell}><View style={styles.topline}><Text style={styles.label}>CAPTAIN’S LOG // {entry.deck}</Text><Text style={styles.state}>PREPARING LOCAL AUDIO</Text></View><Text style={styles.title}>{entry.title}</Text><Text style={styles.transcript}>{entry.transcript}</Text><Text style={styles.note}>BUNDLED VOICE MEDIA IS PREPARING FROM THE INSTALLED APP. THE TRANSCRIPT IS AVAILABLE IMMEDIATELY.</Text></View>;
  return <DownloadedCaptainLog entry={entry} source={source} />;
}

function DownloadedCaptainLog({ entry, source }: { entry: CaptainLogEntry; source: string }) {
  const { settings } = useGame();
  const player = useAudioPlayer(source);
  const status = useAudioPlayerStatus(player);
  useEffect(() => { setAudioModeAsync({ playsInSilentMode: true }).catch(() => undefined); }, []);
  const progress = useMemo(() => status.duration > 0 ? Math.min(100, Math.round((status.currentTime / status.duration) * 100)) : 0, [status.currentTime, status.duration]);
  const togglePlayback = () => {
    if (status.playing) { player.pause(); return; }
    if (status.didJustFinish || (status.duration > 0 && status.currentTime >= status.duration)) player.seekTo(0);
    player.play();
  };
  return <View style={styles.shell}><View style={styles.topline}><Text style={styles.label}>CAPTAIN’S LOG // {entry.deck}</Text><Text style={styles.state}>{status.playing ? "TRANSMITTING" : "BUNDLED AUDIO"}</Text></View><Text style={styles.title}>{entry.title}</Text>{settings.subtitles ? <Text style={styles.transcript}>{entry.transcript}</Text> : <Text style={styles.subtitleOff}>SUBTITLES DISABLED IN ACCESSIBILITY SETTINGS</Text>}<View style={styles.track}><View style={[styles.fill, { width: `${progress}%` }]} /></View><Pressable accessibilityRole="button" accessibilityLabel={status.playing ? "Pause Captain’s Log narration" : "Play Captain’s Log narration"} onPress={togglePlayback} style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}><Text style={styles.buttonText}>{status.playing ? "PAUSE LOG" : "PLAY CAPTAIN’S LOG"}</Text></Pressable><Text style={styles.note}>BUNDLED VOICE MEDIA IS AVAILABLE FOR OFFLINE PLAYBACK.</Text></View>;
}

const styles = StyleSheet.create({ shell: { gap: 8, marginTop: 4, padding: 13, borderWidth: 1, borderColor: "#6A4B2E", borderRadius: 15, backgroundColor: "#15100BDE" }, topline: { flexDirection: "row", justifyContent: "space-between", gap: 8 }, label: { color: "#D4A74F", fontSize: 9, fontWeight: "900", letterSpacing: 0.8 }, state: { color: "#7DBBAB", fontSize: 8, fontWeight: "900", letterSpacing: 0.6 }, title: { color: "#F5E9D5", fontSize: 13, fontWeight: "900", letterSpacing: 0.45 }, transcript: { color: "#E8DCC7", fontSize: 12, lineHeight: 18, fontStyle: "italic" }, subtitleOff: { color: "#B19876", fontSize: 10, fontWeight: "800", letterSpacing: 0.45 }, track: { height: 3, overflow: "hidden", borderRadius: 4, backgroundColor: "#382819" }, fill: { height: "100%", borderRadius: 4, backgroundColor: "#D4A74F" }, button: { minHeight: 37, borderRadius: 10, alignItems: "center", justifyContent: "center", borderWidth: 1, borderColor: "#B88936", backgroundColor: "#2D2014" }, buttonPressed: { opacity: 0.72, transform: [{ scale: 0.98 }] }, buttonText: { color: "#F5E9D5", fontSize: 10, fontWeight: "900", letterSpacing: 0.7 }, note: { color: "#A98D68", fontSize: 8, lineHeight: 12, fontWeight: "800", letterSpacing: 0.35 } });
