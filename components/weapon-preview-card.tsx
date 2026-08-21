import { Animated, StyleSheet, Text, View } from "react-native";
import { useEffect, useRef } from "react";

import type { Weapon } from "@/lib/game-data";
import type { WeaponTelemetry } from "@/lib/weapon-telemetry";

export function WeaponPreviewCard({ weapon, telemetry, index, reducedMotion }: { weapon: Weapon; telemetry: WeaponTelemetry; index: number; reducedMotion: boolean }) {
  const drift = useRef(new Animated.Value(0)).current;
  const glow = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    if (reducedMotion) { drift.setValue(0.5); glow.setValue(0.35); return; }
    const driftLoop = Animated.loop(Animated.sequence([Animated.timing(drift, { toValue: 1, duration: 2100 + index * 140, useNativeDriver: true }), Animated.timing(drift, { toValue: 0, duration: 2100 + index * 140, useNativeDriver: true })]));
    const glowLoop = Animated.loop(Animated.sequence([Animated.timing(glow, { toValue: 1, duration: 1500, useNativeDriver: true }), Animated.timing(glow, { toValue: 0, duration: 1500, useNativeDriver: true })]));
    driftLoop.start(); glowLoop.start(); return () => { driftLoop.stop(); glowLoop.stop(); };
  }, [drift, glow, index, reducedMotion]);
  const shift = drift.interpolate({ inputRange: [0, 1], outputRange: [-4, 7] });
  const opacity = glow.interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.22, 0.85, 0.22] });
  const barrelWidth = 48 + ((index * 9) % 24);
  return <View style={[styles.preview, { borderColor: `${telemetry.accent}88` }]}><Animated.View style={[styles.scan, { backgroundColor: telemetry.accent, opacity, transform: [{ translateX: shift }] }]} /><View style={styles.ghostRail} /><Animated.View style={[styles.weaponSilhouette, { transform: [{ translateX: shift }] }]}><View style={[styles.stock, { backgroundColor: telemetry.accent }]} /><View style={[styles.receiver, { borderColor: telemetry.accent }]} /><View style={[styles.barrel, { width: barrelWidth, backgroundColor: telemetry.accent }]} /></Animated.View><Text style={[styles.profile, { color: telemetry.accent }]}>{telemetry.profile}</Text></View>;
}

const styles = StyleSheet.create({ preview: { height: 86, overflow: "hidden", borderWidth: 1, borderRadius: 9, justifyContent: "center", paddingHorizontal: 12, backgroundColor: "#100D0A" }, scan: { position: "absolute", top: 0, bottom: 0, width: 2 }, ghostRail: { position: "absolute", left: 12, right: 12, height: 1, top: 34, backgroundColor: "#68533A" }, weaponSilhouette: { flexDirection: "row", alignItems: "center", alignSelf: "center" }, stock: { width: 24, height: 17, borderRadius: 3, opacity: 0.7 }, receiver: { width: 35, height: 22, borderWidth: 2, borderRadius: 4, backgroundColor: "#1D1711" }, barrel: { height: 7, borderRadius: 3, opacity: 0.82 }, profile: { position: "absolute", left: 12, bottom: 8, fontSize: 7, fontWeight: "900", letterSpacing: 0.65 } });
