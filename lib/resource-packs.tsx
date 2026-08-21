import AsyncStorage from "@react-native-async-storage/async-storage";
import { Asset } from "expo-asset";
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type PropsWithChildren } from "react";

import { defaultHarborGalleryPreferences, normalizeHarborGalleryPreferences, type HarborGalleryPreferences } from "@/lib/harbor-gallery-preferences";
import { resourcePackAssetModules } from "@/lib/resource-pack-assets";
import { resourcePackBytes, resourcePackManifest, type ResourcePackId } from "@/lib/resource-pack-manifest";

export type ResourcePackStatus = "not_downloaded" | "downloading" | "installed" | "failed" | "wifi_required" | "storage_warning" | "unavailable";
export type ResourcePackState = { status: ResourcePackStatus; files: Record<string, string>; downloadedBytes: number; totalBytes: number | null; installedBytes: number; installedVersion: string | null; error: string | null };
export type ResourcePackStorage = { usedBytes: number; freeBytes: number | null };
export type ResourcePackUpdateCheck = { status: "idle" | "checking" | "ready" | "wifi_required" | "failed"; checkedAt: number | null; available: ResourcePackId[]; error: string | null };
type ResourcePackSession = { packs: Record<ResourcePackId, ResourcePackState>; storage: ResourcePackStorage; updateCheck: ResourcePackUpdateCheck; harborGallery: HarborGalleryPreferences; hydrated: boolean; downloadPack: (id: ResourcePackId, allowLowStorage?: boolean) => Promise<void>; cancelPack: (id: ResourcePackId) => Promise<void>; removePack: (id: ResourcePackId) => Promise<void>; assetUriFor: (id: ResourcePackId, assetId: string) => string | null; setHarborFavorite: (favorite: boolean) => void; setHarborCaption: (caption: string) => void; checkForUpdates: () => Promise<void> };

const HARBOR_GALLERY_KEY = "nightfall.harbor_gallery_preferences.v1";
const packIds = Object.keys(resourcePackManifest) as ResourcePackId[];
const initialState = (): Record<ResourcePackId, ResourcePackState> => Object.fromEntries(packIds.map((id) => [id, { status: "not_downloaded", files: {}, downloadedBytes: 0, totalBytes: resourcePackBytes(resourcePackManifest[id]), installedBytes: 0, installedVersion: null, error: null }])) as Record<ResourcePackId, ResourcePackState>;
const bundledBytes = packIds.reduce((total, id) => total + resourcePackBytes(resourcePackManifest[id]), 0);
const ResourcePackContext = createContext<ResourcePackSession | null>(null);

export function ResourcePackProvider({ children }: PropsWithChildren) {
  const [packs, setPacks] = useState<Record<ResourcePackId, ResourcePackState>>(initialState);
  const [harborGallery, setHarborGallery] = useState<HarborGalleryPreferences>(defaultHarborGalleryPreferences);
  const [hydrated, setHydrated] = useState(false);
  const [updateCheck, setUpdateCheck] = useState<ResourcePackUpdateCheck>({ status: "ready", checkedAt: Date.now(), available: [], error: "All campaign media is bundled in this build." });
  const storage: ResourcePackStorage = { usedBytes: bundledBytes, freeBytes: null };
  const update = useCallback((id: ResourcePackId, patch: Partial<ResourcePackState>) => setPacks((current) => ({ ...current, [id]: { ...current[id], ...patch } })), []);
  const prepareBundledPack = useCallback(async (id: ResourcePackId) => {
    const pack = resourcePackManifest[id];
    update(id, { status: "downloading", files: {}, downloadedBytes: 0, error: null });
    try {
      const files: Record<string, string> = {};
      let preparedBytes = 0;
      for (const entry of pack.assets) {
        const bundledModule = resourcePackAssetModules[id][entry.id];
        if (!bundledModule) throw new Error(`Bundled module missing for ${id}/${entry.id}.`);
        const asset = Asset.fromModule(bundledModule);
        await asset.downloadAsync();
        const uri = asset.localUri ?? asset.uri;
        if (!uri) throw new Error("Bundled asset path was unavailable.");
        files[entry.id] = uri;
        preparedBytes += entry.bytes;
        update(id, { status: "downloading", files: { ...files }, downloadedBytes: preparedBytes });
      }
      update(id, { status: "installed", files, downloadedBytes: preparedBytes, installedBytes: preparedBytes, installedVersion: pack.version, error: null });
    } catch (error) {
      update(id, { status: "failed", files: {}, downloadedBytes: 0, installedBytes: 0, error: error instanceof Error ? error.message : "Bundled asset preparation failed." });
    }
  }, [update]);
  useEffect(() => { Promise.all(packIds.map((id) => prepareBundledPack(id))).finally(() => setHydrated(true)); }, [prepareBundledPack]);
  useEffect(() => { AsyncStorage.getItem(HARBOR_GALLERY_KEY).then((stored) => { if (stored) setHarborGallery(normalizeHarborGalleryPreferences(JSON.parse(stored))); }).catch(() => undefined); }, []);
  const updateHarborGallery = useCallback((patch: Partial<HarborGalleryPreferences>) => { setHarborGallery((current) => { const next = normalizeHarborGalleryPreferences({ ...current, ...patch }); AsyncStorage.setItem(HARBOR_GALLERY_KEY, JSON.stringify(next)).catch(() => undefined); return next; }); }, []);
  const checkForUpdates = useCallback(async () => setUpdateCheck({ status: "ready", checkedAt: Date.now(), available: [], error: "All campaign media is bundled in this build." }), []);
  const removePack = useCallback(async (id: ResourcePackId) => { await prepareBundledPack(id); }, [prepareBundledPack]);
  const value = useMemo<ResourcePackSession>(() => ({ packs, storage, updateCheck, harborGallery, hydrated, downloadPack: prepareBundledPack, cancelPack: async (id) => prepareBundledPack(id), removePack, assetUriFor: (id, assetId) => packs[id].files[assetId] ?? null, setHarborFavorite: (favorite) => updateHarborGallery({ favorite }), setHarborCaption: (caption) => updateHarborGallery({ caption }), checkForUpdates }), [packs, storage, updateCheck, harborGallery, hydrated, prepareBundledPack, removePack, updateHarborGallery, checkForUpdates]);
  return <ResourcePackContext.Provider value={value}>{children}</ResourcePackContext.Provider>;
}

export function useResourcePacks() { const context = useContext(ResourcePackContext); if (!context) throw new Error("useResourcePacks must be used within ResourcePackProvider"); return context; }
