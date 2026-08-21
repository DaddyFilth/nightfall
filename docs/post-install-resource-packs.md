# Post-Install Resource Packs

Blood & Brass keeps its base campaign usable after installation without any additional download. Optional presentation resources are made available only through a player-initiated content screen. The app does not schedule background downloads, silently consume cellular data, request an account, or require an API key.

| Pack | Content | Player control | Offline behavior |
|---|---|---|---|
| Captain’s Log Cinematics | Three voiced logbook transmissions | Player taps **Download Voice Archive** after reviewing the transfer size. | Transcript-first cinematics remain usable without the archive; downloaded narration is cached locally. |
| Brasswake Harbor // High Resolution | High-fidelity harbor hero artwork | Player taps **Download on Wi‑Fi**. The installed app verifies reachable Wi‑Fi before transfer. | Standard hero artwork remains in place until the enhanced art cache is complete. |

The content manager stores downloaded files in the application document directory so an installed pack remains usable offline. It persists install metadata locally, exposes transfer progress and expected bytes when provided by the server, and allows the player to retry an interrupted transfer, cancel an active transfer, or remove a completed pack. A network change never initiates a download by itself.

> The Wi‑Fi condition protects the high-resolution art transfer only. It is a user-facing delivery policy, not a connectivity promise: a reachable connection is still required for the initial transfer.
