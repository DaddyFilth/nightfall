export type ResourcePackId = "cinematic_audio" | "harbor_art_hd";

export type ResourcePackAsset = { id: string; fileName: string; bytes: number };
export type ResourcePackDefinition = { id: ResourcePackId; version: string; title: string; eyebrow: string; description: string; releaseNotes: string[]; wifiOnly: false; assets: ResourcePackAsset[] };

export const storageBudgetReserveBytes = 5 * 1024 * 1024;

export const resourcePackManifest: Record<ResourcePackId, ResourcePackDefinition> = {
  cinematic_audio: {
    id: "cinematic_audio", version: "1.2.0", eyebrow: "Bundled voice archive", title: "CAPTAIN’S LOG CINEMATICS", description: "Three voiced Bloodwake logbook transmissions are packaged with the installed app and prepared locally on first launch.", releaseNotes: ["Voice transmissions are included in the APK.", "No post-install archive download is required."], wifiOnly: false,
    assets: [
      { id: "arrival", fileName: "brasswake-arrival.mp3", bytes: 138780 },
      { id: "descent", fileName: "dockyard-descent.mp3", bytes: 168090 },
      { id: "admiral", fileName: "drowned-admiral.mp3", bytes: 149908 },
    ],
  },
  harbor_art_hd: {
    id: "harbor_art_hd", version: "1.2.0", eyebrow: "Bundled harbor artwork", title: "BRASSWAKE HARBOR // HIGH RESOLUTION", description: "The high-resolution Brasswake harbor panorama is packaged inside the installed app for offline viewing.", releaseNotes: ["Harbor artwork is included in the APK.", "No Wi‑Fi transfer or update check is required."], wifiOnly: false,
    assets: [{ id: "harbor", fileName: "brasswake-harbor-highres-bundled.png", bytes: 501405 }],
  },
};

export function resourcePackBytes(pack: ResourcePackDefinition): number { return pack.assets.reduce((total, asset) => total + asset.bytes, 0); }
export function resourcePackSizeLabel(pack: ResourcePackDefinition): string { return `${Math.max(1, Math.round(resourcePackBytes(pack) / 1024))} KB BUNDLED`; }
export function isWifiEligible(_networkType: string | null | undefined): boolean { return true; }
export function formatArchiveBytes(bytes: number | null | undefined): string { if (!bytes || bytes <= 0) return "0 KB"; if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`; return `${(bytes / (1024 * 1024)).toFixed(bytes >= 10 * 1024 * 1024 ? 0 : 1)} MB`; }
export function storageBudgetForDownload(freeBytes: number | null, transferBytes: number | null): { transferBytes: number | null; reserveBytes: number; requiredBytes: number | null; isTight: boolean } { const requiredBytes = transferBytes === null ? null : transferBytes + storageBudgetReserveBytes; return { transferBytes, reserveBytes: storageBudgetReserveBytes, requiredBytes, isTight: false }; }
