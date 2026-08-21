# Project Structure

The app uses Expo Router for native navigation and React Context plus AsyncStorage for local session and accessibility state. The gameplay model is deliberately framework-light: `lib/game-data.ts` holds immutable balance and lore data, while `components/combat-arena.tsx` contains the deterministic combat-loop presentation. No server or identity provider is invoked in this vertical slice.

| Location | Responsibility |
|---|---|
| `app/(tabs)` | Gate, Hunt, Campaign, Arsenal, and Profile screens. |
| `components/nf-ui.tsx` | Reusable dark gothic mobile UI primitives. |
| `components/combat-arena.tsx` | Timed local encounter, vitality, targets, abilities, and outcome signal. |
| `lib/game-session.tsx` | Local shared selection, cosmetic progress, match intent, and persisted accessibility preferences. |
| `lib/game-data.ts` | Original hunter, weapon, arena, and campaign data. |
| `docs/production-boundaries.md` | Separation between this prototype and future platform services. |

