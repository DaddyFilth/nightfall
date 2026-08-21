import { TRPCError } from "@trpc/server";
import { publicProcedure, router } from "./_core/trpc";
import { matchIntentSchema, receiptSubmissionSchema, consentSchema } from "./production-contracts";
import { getProductionReadiness } from "./production-readiness";
import { verifyReceipt } from "./receipt-verifier";

export const productionRouter = router({
  readiness: publicProcedure.query(() => getProductionReadiness()),

  matchIntent: publicProcedure.input(matchIntentSchema).mutation(({ input }) => {
    const readiness = getProductionReadiness();
    if (input.transport === "steam_p2p" && !readiness.godotSteamP2P.configured) {
      return { accepted: false, state: "unavailable" as const, reason: "steam_p2p_not_configured" };
    }
    if (input.transport === "dedicated_future") {
      return { accepted: false, state: "unavailable" as const, reason: "dedicated_transport_not_deployed" };
    }
    return { accepted: true, state: "lan_only" as const, mode: input.mode };
  }),

  submitReceipt: publicProcedure.input(receiptSubmissionSchema).mutation(async ({ input }) => verifyReceipt(input)),

  recordConsent: publicProcedure.input(consentSchema).mutation(({ input }) => {
    if (input.personalizedAdsAllowed && !input.adsAllowed) {
      throw new TRPCError({ code: "BAD_REQUEST", message: "Personalized advertising cannot be enabled while ads are disabled." });
    }
    return { accepted: true, persisted: false, policyVersion: input.policyVersion };
  }),
});

