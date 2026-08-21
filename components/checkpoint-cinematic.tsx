import { useEffect, useRef } from "react";
import { Animated, Pressable, StyleSheet, Text, View } from "react-native";
import type { CinematicScene } from "@/lib/ashes-below-cinematics";
import { Eyebrow } from "@/components/nf-ui";
import { BrasswakeAtmosphere } from "@/components/brasswake-atmosphere";
import { CaptainsLogPlayer } from "@/components/captains-log-player";
import { captainLogForCheckpoint } from "@/lib/captains-log";

export function CheckpointCinematic({ scene, onContinue }: { scene: CinematicScene; onContinue: () => void }) {
  const opacity = useRef(new Animated.Value(0)).current;
  const rise = useRef(new Animated.Value(20)).current;
  const captainLog = captainLogForCheckpoint(scene.checkpoint);
  useEffect(() => { opacity.setValue(0); rise.setValue(20); Animated.parallel([Animated.timing(opacity, { toValue: 1, duration: 360, useNativeDriver: true }), Animated.timing(rise, { toValue: 0, duration: 420, useNativeDriver: true })]).start(); }, [scene.checkpoint, opacity, rise]);
  return <View style={styles.overlay}><View style={[styles.eclipse, { borderColor: scene.color }]} /><BrasswakeAtmosphere compact /><View style={[styles.axis, { backgroundColor: scene.color }]} /><Animated.View style={[styles.card, { opacity, transform: [{ translateY: rise }] }]}><Eyebrow color={scene.color}>{scene.chapter}</Eyebrow><Text style={styles.timestamp}>{scene.timestamp}</Text><Text style={styles.headline}>{scene.headline}</Text><Text style={styles.context}>{scene.context}</Text><View style={[styles.transmission, { borderLeftColor: scene.color }]}><Text style={styles.transmissionLabel}>ARCHIVE TRANSMISSION</Text><Text style={styles.transmissionCopy}>{scene.transmission}</Text></View>{captainLog ? <CaptainsLogPlayer entry={captainLog} /> : null}<Pressable accessibilityRole="button" onPress={onContinue} style={({ pressed }) => [styles.continue, { backgroundColor: scene.color, opacity: pressed ? 0.82 : 1 }]}><Text style={styles.continueText}>CONTINUE TO OBJECTIVE</Text></Pressable></Animated.View></View>;
}

const styles = StyleSheet.create({ overlay: { position: "absolute", zIndex: 20, top: 0, right: 0, bottom: 0, left: 0, justifyContent: "center", padding: 22, overflow: "hidden", backgroundColor: "#07070CF4" }, eclipse: { position: "absolute", width: 430, height: 430, borderRadius: 215, borderWidth: 36, top: -155, right: -145, opacity: 0.38 }, axis: { position: "absolute", width: 2, height: "100%", left: 28, opacity: 0.65 }, card: { gap: 12, padding: 22, borderWidth: 1, borderColor: "#4F3A62", borderRadius: 24, backgroundColor: "#15101E" }, timestamp: { color: "#BDB4C9", fontSize: 10, fontWeight: "900", letterSpacing: 1.1 }, headline: { color: "#F5F0E9", fontSize: 28, lineHeight: 34, fontWeight: "900" }, context: { color: "#D0C7DA", fontSize: 13, lineHeight: 20 }, transmission: { gap: 5, borderLeftWidth: 3, paddingLeft: 11, marginTop: 2 }, transmissionLabel: { color: "#A9A3B5", fontSize: 9, fontWeight: "900", letterSpacing: 0.8 }, transmissionCopy: { color: "#F5F0E9", fontSize: 12, lineHeight: 18, fontStyle: "italic" }, continue: { marginTop: 4, borderRadius: 14, minHeight: 50, alignItems: "center", justifyContent: "center" }, continueText: { color: "#09070D", fontSize: 11, fontWeight: "900", letterSpacing: 0.65 } });
