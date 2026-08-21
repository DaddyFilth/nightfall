import { describe, expect, it } from "vitest";
import { mergeNativeCampaignCompletion, NATIVE_CAMPAIGN_COMPLETION_SCHEMA, parseNativeCampaignCompletion, serializeNativeCampaignCompletion } from "../lib/native-campaign-completion";

describe("native campaign completion records", () => {
  const record = { schema: NATIVE_CAMPAIGN_COMPLETION_SCHEMA, completedMission: 4, defeatedThrough: 4, completedTitle: "SABLE WAKE", recordedAtUnix: 1724200000 } as const;

  it("accepts a bounded local Godot completion record", () => {
    expect(parseNativeCampaignCompletion(record)).toEqual(record);
    expect(mergeNativeCampaignCompletion(2, record)).toBe(4);
  });

  it("rejects malformed or order-breaking records", () => {
    expect(parseNativeCampaignCompletion({ ...record, schema: "wrong" })).toBeNull();
    expect(parseNativeCampaignCompletion({ ...record, defeatedThrough: 2 })).toBeNull();
  });

  it("serializes only a previously validated local record for device export", () => {
    expect(JSON.parse(serializeNativeCampaignCompletion(record))).toEqual(record);
  });
});
