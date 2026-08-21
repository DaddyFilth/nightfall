# Build Plan

The mobile prototype is organized around a single risk slice: a deterministic, touch-first offline combat encounter. It must visually communicate gameplay state, end reliably, and return a factual debrief before surrounding content is expanded.

| Slice | Evidence of completion |
|---|---|
| **Combat core** | The player can use Fire, Veil Step, and Shadow Leap to defeat local targets; vitality, shard count, time, and objective update visibly. |
| **Mode flow** | Gate → setup or campaign briefing → combat → debrief → rematch/change hunter works without dead ends. |
| **Metadata surfaces** | Arsenal, profile, consent/entitlement explanation, and accessibility controls represent the requested direction without claiming real store, ad, or online functionality. |
| **Safety boundary** | Every network, purchase, and ad-facing surface identifies this build as a local prototype. No live transaction or advertisement call is made. |

## Verification Criteria

The vertical slice is complete when the TypeScript check passes, its core route renders on mobile web preview, and the active combat state is visible rather than represented by a static mock. The final validation will also verify that settings changes are retained locally and that the in-app billing explanation never grants a real entitlement.

