import { describe, expect, it } from "vitest";
import { formatArchiveBytes, isWifiEligible, resourcePackManifest, resourcePackSizeLabel, storageBudgetForDownload } from "../lib/resource-pack-manifest";

describe("bundled campaign resources", () => {
	it("bundles voiced cinematics with the installed APK", () => {
		expect(resourcePackManifest.cinematic_audio.wifiOnly).toBe(false);
		expect(resourcePackManifest.cinematic_audio.version).toBe("1.2.0");
		expect(resourcePackManifest.cinematic_audio.releaseNotes).toHaveLength(2);
		expect(resourcePackSizeLabel(resourcePackManifest.cinematic_audio)).toBe("446 KB BUNDLED");
	});

	it("bundles high-resolution harbor art with no Wi‑Fi requirement", () => {
		expect(resourcePackManifest.harbor_art_hd.wifiOnly).toBe(false);
      expect(resourcePackSizeLabel(resourcePackManifest.harbor_art_hd)).toBe("490 KB BUNDLED");
		expect(isWifiEligible("WIFI")).toBe(true);
		expect(isWifiEligible("CELLULAR")).toBe(true);
		expect(isWifiEligible("UNKNOWN")).toBe(true);
      expect(formatArchiveBytes(501405)).toBe("490 KB");
		expect(formatArchiveBytes(0)).toBe("0 KB");
	});

	it("does not require transfer storage because media is packaged", () => {
      expect(storageBudgetForDownload(2 * 1024 * 1024, 501405).isTight).toBe(false);
      expect(storageBudgetForDownload(8 * 1024 * 1024, 501405).isTight).toBe(false);
	});
});
