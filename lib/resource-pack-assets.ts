import type { ResourcePackId } from "@/lib/resource-pack-manifest";

/**
 * Static Metro asset modules used only by the native runtime provider.
 * Keeping them outside metadata allows Node-based unit tests to inspect the
 * offline manifest without attempting to parse binary MP3 or PNG payloads.
 */
export const resourcePackAssetModules: Record<ResourcePackId, Record<string, number>> = {
  cinematic_audio: {
    arrival: require("../assets/audio/captains-log/brasswake-arrival.mp3"),
    descent: require("../assets/audio/captains-log/dockyard-descent.mp3"),
    admiral: require("../assets/audio/captains-log/drowned-admiral.mp3"),
  },
  harbor_art_hd: {
    harbor: require("../assets/images/harbor/brasswake-harbor-highres-bundled.png"),
  },
};
