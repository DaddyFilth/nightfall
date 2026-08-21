# Blood & Brass: Direct Android Testing and Release Pack

## Purpose and distribution boundary

This pack supports **private physical-device testing** without enrolling in a paid app-store developer program. The associated EAS `preview` profile produces a signed Android APK for direct installation. It is appropriate for the development team and explicitly invited testers; it is not a substitute for a public store release.

> The signed production artifact is an Android App Bundle (`.aab`) intended for a store pipeline. A physical Android device cannot install an `.aab` directly. Use the separately generated signed preview APK for direct testing.

## Direct Android installation procedure

1. Open the private signed-APK download link on the intended Android device.
2. When Android blocks the install, grant the browser or file manager **Install unknown apps** permission for this one installation. Do not enable this setting globally for unrelated sources.
3. Download the APK, open it from the completed-download notification, and approve the installation prompt.
4. Confirm that the launcher shows **NIGHTFALL: BLOOD HUNT** and open the game. The native session should remain in landscape orientation.
5. After testing, revoke the browser/file manager’s unknown-app permission if it is no longer required.

| Test area | Minimum acceptance check |
|---|---|
| Launch and orientation | The app launches normally and stays landscape until closed. |
| Command deck | The tactical tutorial displays once, dismisses, and the command rail remains usable. |
| Campaign order | Mission 02 and the Observatory remain locked until their preceding mission is defeated. |
| Sound and accessibility | Ambience, interface sounds, volume, subtitles, and vibration settings behave as configured on-device. |
| Combat slice | The Godot Brasswake encounter opens, touch controls respond, and victory/defeat resolution returns a clear result. |
| Local state | Closing and reopening preserves expected local preferences and progress. |

## Platform-neutral store listing draft

| Field | Draft |
|---|---|
| Product name | **Blood & Brass** |
| One-line description | A gothic-steampunk pirate-vampire action prototype set in the Brasswake Dockyards. |
| Long description | Command the Bloodwake Captain through a dark, original 1500s pirate-vampire world of aged brass, oxblood seas, and haunted dockyards. Build a local loadout, follow the Drowned Chart in strict campaign order, and enter the Brasswake combat slice against the Drowned Admiral. Blood & Brass is a landscape-first tactical action prototype with device-local progression, accessible audio controls, original music, and cosmetic rewards that do not affect combat power. |
| Genre positioning | Action; gothic fantasy; tactical shooter prototype. Final platform category should be selected from the platform’s current taxonomy. |
| Audience positioning | Mature-themed fictional action due to supernatural violence and dark fantasy imagery. Complete each platform’s age-rating questionnaire from the shipped build, not from this draft alone. |
| Monetization statement | The current build contains no live advertising, real-money purchases, subscriptions, or gameplay-affecting paid rewards. |
| Data statement | Core gameplay progress and preferences are device-local. Reconfirm every platform’s data-safety form against the final release binary and enabled services. |
| Support contact | Use an actively monitored support email and a public privacy-policy URL before any public release. |

## Release assets to collect before any store submission

- A 512 × 512 or platform-compliant launcher icon sourced from `assets/images/icon.png`.
- At least three screenshots captured on a physical Android device: command deck, campaign map, and live Brasswake combat.
- A short gameplay video recorded from the signed build, with no copyrighted third-party music or branding.
- Final support email, privacy-policy URL, and age-rating responses.
- A completed test report using the acceptance checks above.

## Reusable testing-track plan

| Stage | Audience | Delivery method | Exit criteria |
|---|---|---|---|
| Direct device test | Development team and invited testers | Signed preview APK | Installation, launch, campaign, audio, and combat checks pass. |
| Closed test | A controlled tester group on a chosen future platform | That platform’s private testing mechanism | Device coverage, crash review, feedback triage, and release notes complete. |
| Public release | General audience | Store release only after platform enrollment and policy completion | Listing, data disclosures, content ratings, signing, and support surfaces are approved. |

## Build commands

```bash
# Direct-install signed APK for private device testing
npx eas-cli@latest build --platform android --profile preview

# Store-oriented signed Android App Bundle, for a future enrolled store account
npx eas-cli@latest build --platform android --profile production
```

Do not submit the application or create a public listing without the account owner’s explicit approval.
