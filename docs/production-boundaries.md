# Production Boundaries and Integration Path

## What This Build Is

This repository contains a local Expo mobile **experience prototype**. It implements a deterministic touch-screen encounter and non-transactional representations of the campaign, arsenal, accessibility, privacy, and entitlement surfaces. It does not communicate with a backend or a third-party SDK.

## What This Build Does Not Claim

The build does not ship the specified Godot 4 project, Windows/Steam build, Android Gradle game export, peer-to-peer networking, host validation, dedicated-server migration, Google Play Billing, StoreKit 2, Steam commerce, real receipt validation, AdMob, consent-management platform, advertising SDK, PostgreSQL entitlement model, Redis, analytics service, or production telemetry pipeline.

## Future Adapter Boundaries

| Capability | Required future adapter | Prototype behavior today |
|---|---|---|
| Android purchase | Google Play Billing non-consumable adapter for `nightfall_ad_free_forever` | A disabled explanatory control; it neither starts checkout nor changes entitlement. |
| iOS purchase | StoreKit 2 adapter and signed production build | Not connected. |
| Entitlement validation | TLS receipt submission, platform-side validation, short-lived signed entitlement state | No receipt or entitlement exists locally. |
| Advertisements | Consent-aware mobile ad adapter with strict non-combat placement caps | No advertisement is requested or shown. |
| Multiplayer | ENet for LAN and an approved P2P transport for production, with host validation | Offline deterministic simulation only. |
| Analytics | Opt-in/consent-aware batched event intake with minimization and deletion handling | No telemetry is emitted. |

## Fairness Constraint

Any future purchase, cosmetic, ad, or account feature must never alter weapon damage, fire rate, health, movement, hit registration, XP rate, matchmaking, map access, class access, or outcome rewards. The local completion panel is intentionally cosmetic and narrative only.

