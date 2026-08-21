import * as Linking from "expo-linking";
import { ImageBackground, ScrollView, StyleSheet, Text, View } from "react-native";
import { useRouter } from "expo-router";

import { BrasswakeAtmosphere } from "@/components/brasswake-atmosphere";
import { ActionButton, Eyebrow, Panel } from "@/components/nf-ui";
import { ScreenContainer } from "@/components/screen-container";
import { pirateVisuals } from "@/lib/pirate-visuals";

const SOURCE_URL = "https://github.com/DaddyFilth/nightfall-blood-hunt";

export default function PlayGameScreen() {
  const router = useRouter() as unknown as { push: (route: string) => void; back: () => void };
  const openSource = () => { void Linking.openURL(SOURCE_URL).catch(() => undefined); };
  return <ScreenContainer edges={["top", "left", "right"]}><ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
    <Eyebrow color="#4A877A">Standalone native FPS campaign</Eyebrow><Text style={styles.title}>THE DROWNED CHART</Text><Text style={styles.lead}>The graphical Godot campaign is a separate native Android or iOS build. Its landscape campaign hub deploys ten local first-person missions in strict order, each with three to six animated checkpoints.</Text>
	    <ImageBackground source={pirateVisuals.captain} style={styles.hero} imageStyle={styles.heroImage}><View style={styles.heroShade} /><BrasswakeAtmosphere /><View style={styles.heroCopy}><Eyebrow color="#C7973A">Landscape-first</Eyebrow><Text style={styles.heroTitle}>TAKE THE HELM</Text><Text style={styles.heroText}>Two-thumb controls frame the Bloodwake Captain across a full local FPS campaign of dockyards, ghostlit passages, iron reliquaries, and moonless fleets.</Text></View></ImageBackground>
    <Panel style={styles.orientation}><Eyebrow color="#4A877A">Display & touch</Eyebrow><Text style={styles.panelTitle}>PLAY IN LANDSCAPE</Text><Text style={styles.copy}>The native scene is authored at a 16:9 landscape viewport. The left thumb steers; the right thumb fires the wheel-lock, triggers the cutlass Veil, and dodges Admiral windups.</Text></Panel>
    <Panel><Eyebrow color="#C7973A">What is playable</Eyebrow><Feature number="01" label="TEN FPS LEVELS" detail="Ashes Below through Blood & Brass are available from the native campaign hub, each with a distinct animated level signature and first-person encounter loop." /><Feature number="02" label="CHECKPOINT OBJECTIVES" detail="Every level has three to six local animated checkpoint beacons. Reaching one saves its in-level progress but never bypasses campaign order." /><Feature number="03" label="BLOODWAKE COMBAT" detail="Wheel-lock ADS and reload feedback, cutlass animation, dodges, vitality feedback, directional threat warnings, and live boss telegraphs persist throughout the campaign." /></Panel>
    <Panel><Eyebrow color="#8D2634">Story order</Eyebrow><Text style={styles.panelTitle}>FIRST TO LAST</Text><Text style={styles.copy}>A completed native level records a device-local story flag and opens only the next numbered level. The campaign hub begins with Ashes Below and locks the remaining nine missions until the prior mission is defeated.</Text></Panel>
    <Panel><Eyebrow color="#A89D86">Run a device build</Eyebrow><Text style={styles.panelTitle}>EXPORT, INSTALL, SAIL</Text><Text style={styles.copy}>Open the repository’s <Text style={styles.emphasis}>game/</Text> project with Godot 4.7.2, export through an Android or iOS native toolchain, then install the resulting app on a device. This sandbox can validate the scene headlessly but cannot compile an APK or IPA.</Text></Panel>
    <ActionButton label="VIEW GODOT SOURCE" detail="OPEN BUILD-READY REPOSITORY" tone="cyan" onPress={openSource} /><ActionButton label="WATCH GUIDED DEMO" detail="PORTRAIT COMPANION TOUR" onPress={() => router.push("/demo")} /><ActionButton label="RETURN TO HARBOR" tone="ghost" onPress={() => router.back()} />
  </ScrollView></ScreenContainer>;
}

function Feature({ number, label, detail }: { number: string; label: string; detail: string }) { return <View style={styles.feature}><Text style={styles.featureNumber}>{number}</Text><View style={styles.featureBody}><Text style={styles.featureTitle}>{label}</Text><Text style={styles.featureCopy}>{detail}</Text></View></View>; }

const styles = StyleSheet.create({ content: { padding: 18, paddingBottom: 34, gap: 15 }, title: { color: "#EDE1C4", fontSize: 31, lineHeight: 36, fontWeight: "900", marginTop: -8 }, lead: { color: "#B9AF9A", fontSize: 13, lineHeight: 19 }, hero: { height: 250, overflow: "hidden", borderRadius: 22, borderWidth: 1, borderColor: "#70532B", backgroundColor: "#211A15", justifyContent: "flex-end" }, heroImage: { opacity: 0.82 }, heroShade: { ...StyleSheet.absoluteFillObject, backgroundColor: "#090705B5" }, heroCopy: { padding: 17, gap: 4 }, heroTitle: { color: "#F6E8CF", fontSize: 27, fontWeight: "900", letterSpacing: 0.9 }, heroText: { color: "#E0D1B5", fontSize: 12, lineHeight: 18, maxWidth: "88%" }, orientation: { borderLeftWidth: 3, borderLeftColor: "#4A877A" }, panelTitle: { color: "#EDE1C4", fontSize: 17, lineHeight: 22, fontWeight: "900" }, copy: { color: "#C8BBA1", fontSize: 13, lineHeight: 19 }, feature: { flexDirection: "row", gap: 12, paddingTop: 4 }, featureNumber: { color: "#C7973A", fontSize: 12, fontWeight: "900", letterSpacing: 0.8 }, featureBody: { flex: 1, gap: 2 }, featureTitle: { color: "#EDE1C4", fontSize: 13, fontWeight: "900", letterSpacing: 0.4 }, featureCopy: { color: "#B9AF9A", fontSize: 11, lineHeight: 16 }, emphasis: { color: "#E7CB63", fontWeight: "900" } });
