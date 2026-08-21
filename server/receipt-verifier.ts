import type { ReceiptSubmission } from "./production-contracts";
import { canAcceptReceipt, getProductionReadiness } from "./production-readiness";

export type VerificationResult = {
  accepted: boolean;
  entitlementStatus: "active" | "pending" | "rejected";
  reason: string;
  retryable: boolean;
};

/**
 * Fail-closed receipt entry point. A valid entitlement is never issued from a client Boolean.
 * Native store adapters submit only a provider transaction reference over TLS.
 */
export async function verifyReceipt(input: ReceiptSubmission): Promise<VerificationResult> {
  if (!canAcceptReceipt(input.platform)) {
    return {
      accepted: false,
      entitlementStatus: "pending",
      reason: `${input.platform}_verification_not_configured`,
      retryable: true,
    };
  }

  // Provider network verification is deliberately not simulated. This branch becomes active only
  // after a native store adapter and its server verifier are installed and credentials are configured.
  return {
    accepted: false,
    entitlementStatus: "pending",
    reason: "provider_verifier_not_installed",
    retryable: true,
  };
}

export function receiptVerifierStatus() {
  return getProductionReadiness();
}

