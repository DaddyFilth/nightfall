import { ScrollView, StyleSheet, Text, View } from "react-native";
import { useRouter } from "expo-router";

import { ActionButton, Eyebrow, Panel } from "@/components/nf-ui";
import { ScreenContainer } from "@/components/screen-container";
import { formatArchiveBytes, resourcePackBytes, resourcePackManifest, type ResourcePackId } from "@/lib/resource-pack-manifest";
import { useResourcePacks } from "@/lib/resource-packs";

const packIds = Object.keys(resourcePackManifest) as ResourcePackId[];

export default function ContentPacksScreen() {
  const router = useRouter() as unknown as { back: () => void; push: (route: string) => void };
  const { packs, storage, hydrated } = useResourcePacks();
  return <ScreenContainer edges={["top", "bottom", "left", "right"]}><ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
    <Eyebrow color="#4A877A">Bloodwake offline manifest</Eyebrow><Text style={styles.title}>BUNDLED CAMPAIGN MEDIA</Text><Text style={styles.intro}>Captain’s Log narration, high-resolution harbor art, companion illustrations, core gameplay scripts, and the Godot campaign resources are included with the installed build. Campaign play never waits for a post-install download.</Text>
    <Panel style={styles.meter}><Eyebrow color="#C7973A">Installed content</Eyebrow><Text style={styles.meterValue}>{formatArchiveBytes(storage.usedBytes)} <Text style={styles.meterMuted}>PACKAGED IN THIS BUILD</Text></Text><Text style={styles.meterCopy}>{hydrated ? "Bundled assets have been prepared from local application storage." : "Preparing bundled assets from the installed application…"}</Text></Panel>
    {packIds.map((id) => { const pack = resourcePackManifest[id]; const state = packs[id]; return <Panel key={id} style={styles.pack}><Eyebrow color="#4A877A">{pack.eyebrow} · V{pack.version}</Eyebrow><View style={styles.headingRow}><Text style={styles.packTitle}>{pack.title}</Text><Text style={styles.status}>{state.status === "installed" ? "OFFLINE READY" : "PREPARING"}</Text></View><Text style={styles.copy}>{pack.description}</Text><Text style={styles.size}>{formatArchiveBytes(resourcePackBytes(pack))} INCLUDED IN APK</Text><View style={styles.notes}><Text style={styles.notesLabel}>BUILD CONTENT</Text>{pack.releaseNotes.map((note) => <Text key={note} style={styles.note}>• {note}</Text>)}</View>{id === "harbor_art_hd" ? <ActionButton label="VIEW HARBOR GALLERY" detail="BUNDLED ART · OFFLINE VIEWING" tone="cyan" onPress={() => router.push("/harbor-gallery")} /> : null}</Panel>; })}
    <Panel><Eyebrow color="#A89D86">Offline boundary</Eyebrow><Text style={styles.policy}>No core art, animation, audio, puzzle, boss, campaign, or companion resource is fetched during play. Future optional content updates require a new signed build rather than an in-app transfer.</Text></Panel><ActionButton label="RETURN TO CAPTAIN" tone="ghost" onPress={() => router.back()} />
  </ScrollView></ScreenContainer>;
}

const styles = StyleSheet.create({ content: { padding: 18, gap: 14 }, title: { color: "#EDE1C4", fontSize: 30, lineHeight: 35, fontWeight: "900", marginTop: -7 }, intro: { color: "#B9AF9A", fontSize: 12, lineHeight: 18 }, meter: { borderLeftWidth: 3, borderLeftColor: "#C7973A", gap: 5 }, meterValue: { color: "#EDE1C4", fontSize: 20, fontWeight: "900" }, meterMuted: { color: "#A89D86", fontSize: 9, letterSpacing: 0.6 }, meterCopy: { color: "#B9AF9A", fontSize: 10, lineHeight: 15 }, pack: { gap: 9, borderTopWidth: 2, borderTopColor: "#4A877A" }, headingRow: { flexDirection: "row", justifyContent: "space-between", gap: 8 }, packTitle: { color: "#EDE1C4", fontSize: 16, lineHeight: 21, fontWeight: "900", flex: 1 }, status: { color: "#7DD4BF", fontSize: 9, fontWeight: "900", letterSpacing: 0.55 }, copy: { color: "#B9AF9A", fontSize: 12, lineHeight: 17 }, size: { color: "#E7CB63", fontSize: 9, fontWeight: "900", letterSpacing: 0.45 }, notes: { gap: 3 }, notesLabel: { color: "#A89D86", fontSize: 8, fontWeight: "900", letterSpacing: 0.7 }, note: { color: "#C8BBA1", fontSize: 10, lineHeight: 14 }, policy: { color: "#A89D86", fontSize: 11, lineHeight: 16 } });
