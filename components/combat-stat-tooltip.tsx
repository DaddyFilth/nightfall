import { Pressable, StyleSheet, Text, View } from "react-native";
import { useState } from "react";

import type { CombatStat } from "@/lib/weapon-telemetry";

export function CombatStatTooltip({ stat, accent }: { stat: CombatStat; accent: string }) {
  const [expanded, setExpanded] = useState(false);
  return <Pressable accessibilityRole="button" accessibilityLabel={`${stat.label} ${stat.value}. Tap for field note.`} onPress={() => setExpanded((value) => !value)} style={({ pressed }) => [styles.shell, { borderColor: expanded ? accent : "#51412D" }, pressed && styles.pressed]}><View style={styles.topline}><Text style={styles.label}>{stat.label}</Text><Text style={[styles.value, { color: accent }]}>{stat.value}</Text></View><View style={styles.track}><View style={[styles.fill, { width: `${stat.value}%`, backgroundColor: accent }]} /></View>{expanded ? <Text style={styles.note}>{stat.fieldNote}</Text> : <Text style={styles.hint}>TAP FOR FIELD NOTE</Text>}</Pressable>;
}

const styles = StyleSheet.create({ shell: { flexGrow: 1, flexBasis: "29%", minWidth: 108, gap: 4, padding: 8, borderWidth: 1, borderRadius: 8, backgroundColor: "#110E0B" }, topline: { flexDirection: "row", justifyContent: "space-between", gap: 6 }, label: { color: "#B9AF9A", fontSize: 7, fontWeight: "900", letterSpacing: 0.7 }, value: { fontSize: 11, fontWeight: "900" }, track: { height: 3, borderRadius: 2, overflow: "hidden", backgroundColor: "#33291E" }, fill: { height: "100%", borderRadius: 2 }, hint: { color: "#837762", fontSize: 7, fontWeight: "800", letterSpacing: 0.4 }, note: { color: "#D6C8B1", fontSize: 9, lineHeight: 13 }, pressed: { opacity: 0.72 } });
