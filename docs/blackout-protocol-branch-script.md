# Blackout Protocol — Mission Two Branch Script

## Premise

Mission Two begins at **Eclipse + 31 minutes**, after the Ashes Below engine-core confrontation opens two emergency priorities above Nocturne’s gates. The player can only commit to one route in the current vertical slice. That local decision changes the mission ledger and sets the opening context for the future Observatory mission.

| Branch | Core decision | Three authored scenes | Local outcome |
|---|---|---|---|
| **The Last Platform** | Preserve the trapped night train. | Restore platform beacons, hold the evacuation corridor, and commit the diversion. | Vesper’s map reveals a service route to the Observatory; civilians survive, but the Conductor retains its original timetable. |
| **Following Static** | Pursue the signal courier. | Trace the ghost frequency, choose the unlit trench, and break the courier shell. | Ora decodes a relay-lattice weakness; the Observatory begins with tactical intelligence, but the upper district pays for the delay. |

## State Behavior

The mission stores the selected branch and a three-scene local progress index using the device’s existing local persistence layer. The player sees the unresolved scene, resolves it, and advances the branch ledger. The completion state deliberately remains a **vertical-slice narrative outcome**: it does not create a cloud save, export to a Godot save file, grant gameplay power, or connect to a live campaign service.

## Future Convergence

Both routes converge at the Observatory, but their opening briefing must read the saved branch. The Last Platform path should favor civic trust, open access routes, and a survivor-led introduction. Following Static should favor technical intelligence, alternate relay geometry, and a higher-risk tactical entry. This preserves player authorship without requiring divergent content for every later mission.

