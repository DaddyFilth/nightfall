# Platform Verification Notes

Google’s one-time-product verification endpoint requires the package name, product ID, and purchase token, and returns a purchase object with fields such as the purchase state, acknowledgement state, product ID, purchase token, order ID, and refundable quantity.[1] The planned Android adapter must therefore submit only the client-observed token and product identifier to the secure backend; the backend is responsible for calling the Google Play Developer API and recording the authoritative result.

Apple’s App Store Server API operates from the game backend over TLS 1.2 or later. API calls are authorized using short-lived JWTs generated from keys held in App Store Connect; transactions are returned as signed JWS information. Apple exposes sandbox endpoints for most testing, including transaction-history verification.[2] The planned iOS adapter must consequently send a StoreKit transaction identifier or signed transaction to the backend, where verification and sandbox/production environment selection occur.

| Store | Client responsibility | Backend responsibility | Prototype status |
|---|---|---|---|
| Google Play | Start the native purchase, retain the token until acknowledged, and submit the token through TLS. | Verify package, product, and token; make entitlement writes idempotent; acknowledge only after successful processing. | Contract to be scaffolded; no Play Console credential is configured. |
| App Store | Start StoreKit 2 purchase and submit verified transaction information. | Create JWT authorization, verify signed transaction data, choose sandbox or production endpoint, and persist entitlement state. | Contract to be scaffolded; no App Store Connect credential is configured. |

## References

[1] [Google Play Developer API — purchases.products.get](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.products/get)

[2] [Apple Developer — App Store Server API](https://developer.apple.com/documentation/appstoreserverapi)

[3] [Godot Engine — High-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)

[4] [Google AdMob — Set up UMP SDK](https://developers.google.com/admob/android/privacy)

## Multiplayer and Consent Boundaries

Godot’s high-level API supports pluggable `MultiplayerPeer` implementations, including ENet, WebRTC, and WebSocket peers. RPC declarations can use authority or any-peer modes, reliable or unreliable transfer modes, and distinct channels; all peers must declare matching RPC signatures.[3] The game contract will reserve reliable RPCs for lobby, checkpoint, score, death, and match-state events, and unreliable ordered traffic for movement and aim snapshots. The match authority—not a client’s self-reported state—will validate combat outcomes.

The Google User Messaging Platform requires consent information to be refreshed on every app launch, requires any needed consent form to be displayed before ads are requested, and may require a visible privacy-options entry point.[4] The advertising adapter will therefore remain disabled until it receives a current consent decision and will never request an ad during active combat, checkpoints, matchmaking, or a failed connection.
