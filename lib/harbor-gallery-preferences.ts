export type HarborGalleryPreferences = { favorite: boolean; caption: string };

export const defaultHarborGalleryPreferences: HarborGalleryPreferences = {
  favorite: false,
  caption: "Black sails, tide engines, and the cathedral fog beneath a captive moon.",
};

export function normalizeHarborGalleryPreferences(value: unknown): HarborGalleryPreferences {
  if (!value || typeof value !== "object") return defaultHarborGalleryPreferences;
  const candidate = value as Partial<HarborGalleryPreferences>;
  return {
    favorite: candidate.favorite === true,
    caption: typeof candidate.caption === "string" && candidate.caption.trim().length > 0 ? candidate.caption.slice(0, 140) : defaultHarborGalleryPreferences.caption,
  };
}
