# NIGHTFALL: BLOOD HUNT — Mobile Interface Design

## Product Intent

This Expo project is an **original, touch-first combat prototype** that represents the mobile experience of *NIGHTFALL: BLOOD HUNT*. The immediate release target is a deterministic offline vertical slice rather than a falsely claimed networked FPS or store-integrated commercial build. It lets a player select a vampire subclass, enter a stylized **Blood Hunt** combat simulation against local Hollowed targets, complete a short encounter, and explore campaign, loadout, profile, settings, and entitlement surfaces.

The interaction model assumes **portrait 9:16**, right-thumb aim and firing, and left-thumb movement. Every primary action is reachable in the lower two-thirds of the display, large enough for a one-handed grip, and paired with visible state feedback. The visual language combines black marble, ultraviolet illumination, and restrained crimson accents; it avoids visual references to third-party game interfaces.

## Screen List

| Screen | Primary content and functionality | Key touch actions |
|---|---|---|
| **Eclipse Gate** | Brand mark, player codename, current clearance level, live local build status, and entry points to play, campaign, arsenal, and profile. | Start Blood Hunt; view campaign; open arsenal or profile. |
| **Blood Hunt Setup** | Offline match settings: subclass, arena, difficulty, and target count. A mode callout clearly states that this build uses local simulation rather than online matchmaking. | Choose subclass; choose arena; start offline match. |
| **Combat Arena** | A portrait combat view with animated neon city geometry, player vitality, blood shards, ability charge, target reticle, local enemy units, touch movement pad, fire control, dash, and ability control. | Hold movement pad; drag aim surface; fire; use Veil Step; dash; pause. |
| **Match Debrief** | Completion state, local score, hits, shards recovered, cosmetic progress, and next actions. No gameplay power is granted. | Rematch; change hunter; return to gate. |
| **Campaign: Ashes Below** | Mission briefing for *The First Eclipse*, showing objectives, enemy roster, difficulty selection, lore fragment, and a playable encounter launch. | Select difficulty; begin the campaign encounter. |
| **Arsenal** | Subclass dossier and an original five-item combat loadout overview. Values are informational and balanced locally; no real purchase or gameplay-enhancing transaction exists. | Switch subclass; inspect weapon cards. |
| **Profile & Entitlements** | Cosmetic title, locally tracked progress, ad preference/entitlement explanation, restore-purchase placeholder, and clear development status. | Review entitlement policy; restore mock status; open privacy notes. |
| **Settings & Accessibility** | Sensitivity, field-of-view presentation scale, camera-shake reduction, high-contrast reticle, colorblind-friendly markers, subtitles, and motion options. | Change toggles or sliders; reset visual controls. |
| **Pause Sheet** | In-combat pause, control reminder, abandon match, and resume. | Resume; abandon to setup. |

## Key User Flows

The primary flow begins at **Eclipse Gate**. The player chooses **Enter Blood Hunt**, selects a subclass and arena, then starts an offline local simulation. The combat screen presents a short objective—defeat the marked Hollowed pack before vitality expires. On reaching the target score, the player moves to **Match Debrief**, where only cosmetic clearance progress is presented. The player may rematch, change subclass, or return to the gate.

The campaign flow begins at the gate’s **Ashes Below** card. The briefing teaches the encounter context and player controls, followed by a campaign-styled battle that uses the same local combat core. Its completion panel grants a narrative log and cosmetic nameplate status only. This keeps the prototype honest about its scope while demonstrating the requested campaign progression direction.

The account flow takes the player from **Profile & Entitlements** to an explanation of the intended non-consumable product. It states that the product removes optional ads permanently on the platform account and confers no gameplay advantage. The button is deliberately a local development demonstration only; no payment is collected, no entitlement is persisted as a production purchase, and no ad is displayed.

## Color Choices

| Role | Color | Usage |
|---|---|---|
| **Void Black** | `#08070C` | Screen base, combat field, outer chrome. |
| **Black Marble** | `#17121F` | Elevated panels and mission cards. |
| **Ultraviolet** | `#8E5CFF` | Navigation focus, energy systems, ability charge. |
| **Eclipse Cyan** | `#3DE6E6` | Targeting, status confirmation, selected states. |
| **Blood Crimson** | `#D93056` | Vitality, urgent calls to action, hostile telegraphs. |
| **Bone White** | `#F5F0E9` | High-legibility primary type. |
| **Fog Gray** | `#A9A3B5` | Supporting copy, disabled instructional labels. |

## Interaction and Accessibility Rules

The combat controls use a persistent lower-left movement pad and lower-right fire control, while the upper-right area holds the pause action. Ability controls sit above the fire button to prevent accidental activation. Button targets are generous, labels remain present in the prototype rather than relying only on iconography, and active controls respond with short haptic feedback where the platform supports it.

The settings surface provides a high-contrast reticle, visible color labels in addition to hue, a motion-reduction mode, subtitle toggle, and camera sensitivity control. Combat feedback must never depend only on color; enemy health, objective progress, and ability readiness also use concise text and shape changes.

## Implementation Boundaries

The project is a **local Expo prototype**, not a Godot 4 production build. It therefore does not claim to ship the requested Windows/Steam version, peer-to-peer multiplayer, native Google Play Billing, StoreKit 2, AdMob, production receipt validation, backend entitlement records, or live analytics. The interfaces and domain terminology are designed so those platform services can be connected later behind explicit adapters without representing mock state as an actual purchase or live network match.

