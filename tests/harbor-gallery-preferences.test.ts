import { describe, expect, it } from "vitest";
import { defaultHarborGalleryPreferences, normalizeHarborGalleryPreferences } from "../lib/harbor-gallery-preferences";

describe("harbor gallery preferences", () => {
  it("restores safe local defaults for missing or malformed preferences", () => {
    expect(normalizeHarborGalleryPreferences(null)).toEqual(defaultHarborGalleryPreferences);
    expect(normalizeHarborGalleryPreferences({ favorite: "yes", caption: "" })).toEqual(defaultHarborGalleryPreferences);
  });

  it("retains a favorite and caps a local caption to the gallery limit", () => {
    const value = normalizeHarborGalleryPreferences({ favorite: true, caption: "x".repeat(160) });
    expect(value.favorite).toBe(true);
    expect(value.caption).toHaveLength(140);
  });
});
