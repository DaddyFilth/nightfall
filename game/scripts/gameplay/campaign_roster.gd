class_name CampaignRoster
extends RefCounted

## The native campaign roster is authored as local data so every level can share
## the same sequential unlock and checkpoint-resume contracts.
const LEVELS: Array[Dictionary] = [
	{"id": 1, "code": "ASHES BELOW", "subtitle": "First Eclipse", "checkpoints": ["Dockyard Breach", "Floodgate Run", "Signal Pyre"], "traversal": {"name": "Floodgate Lift", "mode": "floodgate"}, "boss": {"title": "DROWNED ADMIRAL", "attacks": ["BEACON BREAK", "MIRROR SURGE", "LAST TRAIN IMPACT"], "accent": Color("D93056"), "vitality": 360, "damage": 16}, "archetypes": ["privateer"]},
	{"id": 2, "code": "THE BROKEN COMPASS", "subtitle": "Harbor Divide", "checkpoints": ["Smuggler's Cut", "Lost Crew", "Crane Walk", "Compass Relay"], "traversal": {"name": "Compass Crane", "mode": "crane"}, "boss": {"title": "COMPASS WARDEN", "attacks": ["ANCHOR SWEEP", "CROSSWIND LUNGE", "TRUE NORTH CRASH"], "accent": Color("B68A39"), "vitality": 400, "damage": 17}, "archetypes": ["privateer", "harpoon_raider"]},
	{"id": 3, "code": "THE OBSERVATORY", "subtitle": "Admiral Convergence", "checkpoints": ["Branch Entry", "Aperture Hall", "Defender Ring", "Drowned Admiral"], "traversal": {"name": "Aperture Bridge", "mode": "aperture"}, "boss": {"title": "OBSERVATORY CONDUCTOR", "attacks": ["PULSE BREAK", "LATTICE SHEAR", "CIPHER COLLAPSE"], "accent": Color("4A877A"), "vitality": 440, "damage": 18}, "archetypes": ["privateer", "harpoon_raider"]},
	{"id": 4, "code": "SABLE WAKE", "subtitle": "Blackwater Pursuit", "checkpoints": ["Coal Pier", "Wraith Cargo", "Furnace Lock", "Harpoon Deck", "Wakebreaker"], "traversal": {"name": "Wakebreaker Chain", "mode": "chain"}, "boss": {"title": "WAKEBREAKER HARPOONER", "attacks": ["BLACKWATER CAST", "CHAIN DRAG", "KEELBREACH"], "accent": Color("5E79A6"), "vitality": 480, "damage": 19}, "archetypes": ["harpoon_raider", "lantern_wisp"]},
	{"id": 5, "code": "LANTERNS OF THE LOST", "subtitle": "Ghostlight Passage", "checkpoints": ["Lantern Quay", "Sailor's Maze", "Beacon Keeper"], "traversal": {"name": "Ghostlight Causeway", "mode": "ghostlight"}, "boss": {"title": "LANTERN KEEPER", "attacks": ["WISP VOLLEY", "FOG VEIL", "LAST LIGHT"], "accent": Color("E7CB63"), "vitality": 520, "damage": 20}, "archetypes": ["lantern_wisp", "harpoon_raider"]},
	{"id": 6, "code": "IRON CATHEDRAL", "subtitle": "Brass Reliquary", "checkpoints": ["Foundry Gate", "Choir Gallery", "Bellworks", "Reliquary Floor", "Abbot's Guard", "Iron Saint"], "traversal": {"name": "Reliquary Lift", "mode": "lift"}, "boss": {"title": "IRON SAINT", "attacks": ["CENSER CRUSH", "CHOIR SHOCK", "RELIQUARY FALL"], "accent": Color("8D2634"), "vitality": 580, "damage": 22}, "archetypes": ["iron_abbot", "lantern_wisp"]},
	{"id": 7, "code": "COFFIN FLEET", "subtitle": "Moonless Armada", "checkpoints": ["Hull Walk", "Boarding Line", "Captain's Crypt", "Fleet Command"], "traversal": {"name": "Boarding Chain", "mode": "boarding"}, "boss": {"title": "COFFIN FLEET CAPTAIN", "attacks": ["GRAVE BROADSIDE", "COFFIN RAM", "DEAD RECKONING"], "accent": Color("7A5C97"), "vitality": 630, "damage": 23}, "archetypes": ["coffin_marine", "harpoon_raider"]},
	{"id": 8, "code": "THE THIRTEENTH BELL", "subtitle": "Drowned Hour", "checkpoints": ["Tide Clock", "Graveyard Reef", "Bell Chamber", "Flooded Nave", "Thirteenth Strike"], "traversal": {"name": "Tide Clock Span", "mode": "clock"}, "boss": {"title": "THIRTEENTH BELL RINGER", "attacks": ["TOLL WAVE", "HOURHAND SLICE", "THIRTEENTH STRIKE"], "accent": Color("7F99A4"), "vitality": 680, "damage": 24}, "archetypes": ["bell_tollkeeper", "coffin_marine"]},
	{"id": 9, "code": "RED MERIDIAN", "subtitle": "Bloodline Crossing", "checkpoints": ["Scarlet Sound", "Meridian Bridge", "Vein Engine", "Sunless Horizon"], "traversal": {"name": "Meridian Bridge", "mode": "meridian"}, "boss": {"title": "MERIDIAN BLOOD-ENGINE", "attacks": ["VEIN BURST", "SCARLET ARC", "HORIZON REND"], "accent": Color("B24745"), "vitality": 740, "damage": 25}, "archetypes": ["meridian_sentinel", "bell_tollkeeper"]},
	{"id": 10, "code": "BLOOD & BRASS", "subtitle": "Final Tide", "checkpoints": ["Crownless Harbor", "Brass Leviathan", "Admiral's Wake", "Eclipse Deck", "Bloodwake Oath", "Final Tide"], "traversal": {"name": "Leviathan Spine", "mode": "leviathan"}, "boss": {"title": "BRASS LEVIATHAN", "attacks": ["CROWN BREAK", "LEVIATHAN ROAR", "FINAL TIDE"], "accent": Color("C7973A"), "vitality": 820, "damage": 27}, "archetypes": ["leviathan_guard", "meridian_sentinel"]}
]
const ENCOUNTER_SIZES := [4, 4, 4, 5, 3, 6, 4, 5, 4, 6]
const BOSS_HAZARDS: Array[Dictionary] = [
	{"name": "ECLIPSE TIDE MINES", "mode": "tide_mines", "count": 3, "damage": 10, "interval": 4.6, "accent": Color("D93056")},
	{"name": "CROSSWIND ANCHORS", "mode": "crosswind", "count": 2, "damage": 11, "interval": 4.2, "accent": Color("B68A39")},
	{"name": "APERTURE LATTICE", "mode": "lattice", "count": 4, "damage": 12, "interval": 4.0, "accent": Color("4A877A")},
	{"name": "BLACKWATER KEELWAKE", "mode": "wake", "count": 3, "damage": 13, "interval": 3.9, "accent": Color("5E79A6")},
	{"name": "GHOSTLIGHT FALL", "mode": "ghostlight", "count": 4, "damage": 13, "interval": 3.8, "accent": Color("E7CB63")},
	{"name": "RELIQUARY CENSERS", "mode": "censer", "count": 3, "damage": 15, "interval": 3.7, "accent": Color("8D2634")},
	{"name": "GRAVE BROADSIDE", "mode": "broadside", "count": 3, "damage": 16, "interval": 3.6, "accent": Color("7A5C97")},
	{"name": "THIRTEENTH TOLL", "mode": "toll", "count": 4, "damage": 17, "interval": 3.5, "accent": Color("7F99A4")},
	{"name": "MERIDIAN VEIN ARC", "mode": "arc", "count": 3, "damage": 18, "interval": 3.4, "accent": Color("B24745")},
	{"name": "LEVIATHAN DECKBREAK", "mode": "deckbreak", "count": 5, "damage": 20, "interval": 3.2, "accent": Color("C7973A")}
]
const PUZZLES: Array[Dictionary] = [
	{"name": "FLOODGATE RUNES", "mode": "sequence", "prompt": "FOLLOW THE BRASS CURRENT // BRASS → TEAL → OXBLOOD", "sequence": [0, 2, 1]},
	{"name": "COMPASS CRANE", "mode": "route", "prompt": "FIND TRUE NORTH // FOLLOW THE TEAL SIGNAL", "correctIndex": 2},
	{"name": "APERTURE LATTICE", "mode": "charge", "prompt": "CHARGE THE OXBLOOD APERTURE // HOLD THE BEAM", "anchorIndex": 1, "hitsRequired": 3},
	{"name": "WAKEBREAKER CHAINS", "mode": "binary", "prompt": "RELEASE THE KEEL // STRIKE BRASS + TEAL CHAIN LOCKS", "requiredSet": [0, 2]},
	{"name": "GHOSTLIGHT ROUTE", "mode": "route", "prompt": "FOLLOW THE COLD LANTERN // TEAL IS THE SAFE CAUSEWAY", "correctIndex": 2},
	{"name": "RELIQUARY LIFT", "mode": "charge", "prompt": "ANSWER THE IRON CHOIR // FEED THE OXBLOOD CENSER", "anchorIndex": 1, "hitsRequired": 4},
	{"name": "BOARDING CHAIN", "mode": "sequence", "prompt": "SECURE THE GRAPNEL // BRASS → TEAL → OXBLOOD", "sequence": [0, 2, 1]},
	{"name": "TIDE CLOCK", "mode": "binary", "prompt": "TURN THE DROWNED HOUR // STRIKE BRASS + OXBLOOD HANDS", "requiredSet": [0, 1]},
	{"name": "MERIDIAN BRIDGE", "mode": "route", "prompt": "TRACE THE BLOODLINE // OXBLOOD MARKS THE TRUE BRIDGE", "correctIndex": 1},
	{"name": "LEVIATHAN SPINE", "mode": "charge", "prompt": "WAKE THE FINAL TIDE // POWER THE BRASS SPINE", "anchorIndex": 0, "hitsRequired": 5}
]

static func level_count() -> int:
	return LEVELS.size()

static func is_valid_level(level_id: int) -> bool:
	return level_id >= 1 and level_id <= level_count()

static func level(level_id: int) -> Dictionary:
	if not is_valid_level(level_id):
		return {}
	return LEVELS[level_id - 1].duplicate(true)

static func checkpoint_count(level_id: int) -> int:
	if not is_valid_level(level_id):
		return 0
	return (LEVELS[level_id - 1]["checkpoints"] as Array).size()

static func encounter_size(level_id: int) -> int:
	if not is_valid_level(level_id):
		return 0
	return ENCOUNTER_SIZES[level_id - 1]

static func checkpoint_name(level_id: int, checkpoint_index: int) -> String:
	if not is_valid_level(level_id):
		return ""
	var checkpoints: Array = LEVELS[level_id - 1]["checkpoints"]
	if checkpoint_index < 1 or checkpoint_index > checkpoints.size():
		return ""
	return str(checkpoints[checkpoint_index - 1])

static func level_title(level_id: int) -> String:
	if not is_valid_level(level_id):
		return ""
	return str(LEVELS[level_id - 1]["code"])

static func boss_profile(level_id: int) -> Dictionary:
	if not is_valid_level(level_id):
		return {}
	return (LEVELS[level_id - 1]["boss"] as Dictionary).duplicate(true)

static func traversal_profile(level_id: int) -> Dictionary:
	if not is_valid_level(level_id):
		return {}
	return (LEVELS[level_id - 1]["traversal"] as Dictionary).duplicate(true)

static func enemy_archetype(level_id: int, enemy_index: int) -> String:
	if not is_valid_level(level_id):
		return "privateer"
	var archetypes: Array = LEVELS[level_id - 1]["archetypes"]
	return str(archetypes[enemy_index % archetypes.size()])

static func puzzle_profile(level_id: int) -> Dictionary:
	if not is_valid_level(level_id):
		return {}
	return PUZZLES[level_id - 1].duplicate(true)

static func hazard_profile(level_id: int) -> Dictionary:
	if not is_valid_level(level_id):
		return {}
	return BOSS_HAZARDS[level_id - 1].duplicate(true)
