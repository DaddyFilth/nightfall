import { z } from "zod";

export const GAME_MODES = ["free_for_all", "team_deathmatch", "capture_the_flag"] as const;
export const gameModeSchema = z.enum(GAME_MODES);
export const transportSchema = z.enum(["lan_enet", "steam_p2p", "dedicated_future"]);
export const matchIntentSchema = z.object({
  mode: gameModeSchema,
  transport: transportSchema,
  lobbyCode: z.string().trim().min(4).max(12).optional(),
  region: z.string().trim().min(2).max(16).optional(),
});
export const receiptSubmissionSchema = z.object({
  platform: z.enum(["android", "ios"]),
  productId: z.literal("nightfall_ad_free_forever"),
  transactionId: z.string().trim().min(6).max(512),
  purchaseToken: z.string().trim().min(6).max(8192).optional(),
  signedTransaction: z.string().trim().min(6).max(8192).optional(),
});
export const consentSchema = z.object({
  adsAllowed: z.boolean(),
  personalizedAdsAllowed: z.boolean(),
  policyVersion: z.string().trim().min(1).max(32),
});
export type GameModeId = z.infer<typeof gameModeSchema>;
export type MatchIntent = z.infer<typeof matchIntentSchema>;
export type ReceiptSubmission = z.infer<typeof receiptSubmissionSchema>;

