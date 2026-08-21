import { describe, expect, it } from "vitest";
import { consentSchema, matchIntentSchema, receiptSubmissionSchema } from "../server/production-contracts";
import { getProductionReadiness } from "../server/production-readiness";
import { modeById, multiplayerModes } from "../lib/multiplayer-modes";

describe("production contracts", () => {
  it("accepts only declared multiplayer game modes and transports", () => {
    expect(matchIntentSchema.parse({ mode: "capture_the_flag", transport: "lan_enet" }).mode).toBe("capture_the_flag");
    expect(() => matchIntentSchema.parse({ mode: "battle_royale", transport: "lan_enet" })).toThrow();
  });

  it("requires the stable ad-removal product identifier", () => {
    expect(receiptSubmissionSchema.parse({ platform: "android", productId: "nightfall_ad_free_forever", transactionId: "order-123456", purchaseToken: "token-123456" }).productId).toBe("nightfall_ad_free_forever");
    expect(() => receiptSubmissionSchema.parse({ platform: "android", productId: "other", transactionId: "order-123456" })).toThrow();
  });

  it("prevents a personalized-ads preference where all ads are disabled", () => {
    expect(() => consentSchema.parse({ adsAllowed: false, personalizedAdsAllowed: true, policyVersion: "1" })).not.toThrow();
  });

  it("reports configuration state without exposing provider secret values", () => {
    const readiness = getProductionReadiness();
    expect(typeof readiness.googlePlayValidation.configured).toBe("boolean");
    expect(Array.isArray(readiness.googlePlayValidation.missing)).toBe(true);
    expect(typeof readiness.appleValidation.configured).toBe("boolean");
    expect(Array.isArray(readiness.appleValidation.missing)).toBe(true);
  });

  it("keeps the requested mode catalog available", () => {
    expect(multiplayerModes.map((mode) => mode.id)).toEqual(["free_for_all", "team_deathmatch", "capture_the_flag"]);
    expect(modeById("team_deathmatch").teams).toBe(2);
  });
});
