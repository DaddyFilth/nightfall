# Observatory Conductor — Boss and Reward Design

The Observatory Conductor is the local boss prototype at the relay core. Its vitality has three deterministic bands, and its mechanic label changes when the boss crosses the 240 and 110 vitality thresholds. The branch selected in Blackout Protocol determines the mechanic family and the local cosmetic reward; it does **not** alter damage values, grant a paid advantage, or produce matchmaking power.

| Branch | Phase sequence | Cosmetic completion reward | Gameplay boundary |
|---|---|---|---|
| **The Last Platform** | Beacon Sanctuary → Evacuation Mirrors → Last Train Reversal | **Civic Wayfinder** title and Platform Keeper Banner | The reward is a local visual/profile designation only. |
| **Following Static** | Thirteenth Pulse → Lattice Scission → Cipher Overload | **Relay Breaker** title and Cipher Halo Frame | The reward is a local visual/profile designation only. |

The current Conductor prototype exposes deterministic phase, damage, defeat, and reward signals and is rendered in the Observatory arena. It is not yet connected to player projectile collisions, animation telegraphs, a native mobile save reward inventory, online authority, analytics, monetization, or a production reward service.

## Local Combat Extension

The Conductor now moves laterally toward its tracked player, maintains a live target-layer projectile hurtbox, and owns a phase-scaled `Area3D` attack hitbox. The player has a short local dodge window that accepts the attack but returns a `dodged` resolution without reducing vitality. The phase telegraph now displays the active mechanic and the dodge-window reminder. The native harness completed with `CONDUCTOR_ATTACK_DODGE_PASS hitbox=live movement=tracking dodge=invulnerable`.

This validates a deterministic local combat loop only. It does not include attack animation timing, camera motion, player input on a mobile device, authority reconciliation, latency compensation, or final encounter balancing.
