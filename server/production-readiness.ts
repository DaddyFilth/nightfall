export type Readiness = { configured: boolean; missing: string[] };

function readiness(required: string[]): Readiness {
  const missing = required.filter((key) => !process.env[key]);
  return { configured: missing.length === 0, missing };
}

export function getProductionReadiness() {
  return {
    godotSteamP2P: readiness(["STEAM_APP_ID"]),
    googlePlayValidation: readiness(["GOOGLE_PLAY_PACKAGE_NAME", "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"]),
    appleValidation: readiness(["APPLE_APP_BUNDLE_ID", "APPLE_APP_STORE_ISSUER_ID", "APPLE_APP_STORE_KEY_ID", "APPLE_APP_STORE_PRIVATE_KEY"]),
    androidAds: readiness(["ADMOB_ANDROID_APP_ID", "ADMOB_ANDROID_MAIN_MENU_BANNER_ID", "ADMOB_ANDROID_RESULTS_INTERSTITIAL_ID"]),
    iosAds: readiness(["ADMOB_IOS_APP_ID", "ADMOB_IOS_MAIN_MENU_BANNER_ID", "ADMOB_IOS_RESULTS_INTERSTITIAL_ID"]),
  };
}

export function canAcceptReceipt(platform: "android" | "ios"): boolean {
  const readiness = getProductionReadiness();
  return platform === "android" ? readiness.googlePlayValidation.configured : readiness.appleValidation.configured;
}

