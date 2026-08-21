# Device-Local Cosmetic Inventory

The profile now presents a local **Observatory Collection**. Completing the Observatory through The Last Platform grants the Civic Wayfinder title and Platform Keeper Banner. Completing it through Following Static grants the Relay Breaker title and Cipher Halo Frame. The game session stores only supported cosmetic identifiers in device-local storage and filters malformed entries before displaying them.

| Route | Identifier | Visible profile reward | Gameplay effect |
|---|---|---|---|
| The Last Platform | `civic_wayfinder` | Civic Wayfinder / Platform Keeper Banner | None. Cosmetic designation only. |
| Following Static | `relay_breaker` | Relay Breaker / Cipher Halo Frame | None. Cosmetic designation only. |

The current inventory is a mobile-UI, device-local record. It is not synchronized to Godot, cloud storage, user accounts, purchases, or a production reward service. A future signed runtime bridge may export a validated inventory payload only after the host and Godot integration are configured and tested.

