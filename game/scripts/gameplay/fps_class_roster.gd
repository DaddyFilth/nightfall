extends RefCounted

const SELECTION_PATH := "user://nightfall/fps-class.v1.cfg"
const DEFAULT_CLASS_ID := "duskstalker"
const CLASS_IDS: PackedStringArray = ["duskstalker", "crimson-vanguard", "graveweaver", "lumenfallen", "cinder-surgeon", "iron-revenant"]
const PROFILES := {
	"duskstalker": {"label": "BLOODWAKE CAPTAIN", "callsign": "DUELIST", "accent": Color("C7973A"), "primary_weapon": "BRASSWAKE WHEEL-LOCK", "secondary_weapon": "BLOODWAKE CUTLASS", "ability_name": "MISTWAKE RIPOSTE", "style": "Pistol duels and mist-assisted cutlass pressure.", "move_speed": 5.2, "max_vitality": 100, "primary_damage": 25, "ability_damage": 55, "ability_range": 3.7, "ability_speed": 7.0, "ability_duration": 0.36, "cooldown": 6.0, "reload_duration": 0.58, "melee_duration": 0.42},
	"crimson-vanguard": {"label": "RED MARAUDER", "callsign": "BREACHER", "accent": Color("8D2634"), "primary_weapon": "CATACOMB BLUNDERBUSS", "secondary_weapon": "GALLEON REPEATER", "ability_name": "BOARDING CHARGE", "style": "Scatter breaches followed by corridor suppression.", "move_speed": 4.9, "max_vitality": 116, "primary_damage": 31, "ability_damage": 46, "ability_range": 4.4, "ability_speed": 8.0, "ability_duration": 0.30, "cooldown": 7.0, "reload_duration": 0.72, "melee_duration": 0.48},
	"graveweaver": {"label": "TIDE HEXER", "callsign": "HEXER", "accent": Color("4A877A"), "primary_weapon": "OSSUARY CENSER CARBINE", "secondary_weapon": "SALTBONE SICKLE", "ability_name": "BONE NET", "style": "Cursed bolts, controlled routes, and hooked melee arcs.", "move_speed": 5.4, "max_vitality": 94, "primary_damage": 23, "ability_damage": 48, "ability_range": 4.8, "ability_speed": 6.4, "ability_duration": 0.42, "cooldown": 5.7, "reload_duration": 0.52, "melee_duration": 0.52},
	"lumenfallen": {"label": "BRASS CORSAIR", "callsign": "MARKSMAN", "accent": Color("C7973A"), "primary_weapon": "ASTRAL HARPOON", "secondary_weapon": "SUNSPIKE RAPIER", "ability_name": "SAILBURST THRUST", "style": "Long-lane harpoon shots and rapid precision recovery.", "move_speed": 5.3, "max_vitality": 92, "primary_damage": 38, "ability_damage": 43, "ability_range": 4.0, "ability_speed": 7.8, "ability_duration": 0.25, "cooldown": 6.4, "reload_duration": 0.80, "melee_duration": 0.34},
	"cinder-surgeon": {"label": "CINDER SURGEON", "callsign": "SURGEON", "accent": Color("D96A3A"), "primary_weapon": "EMBER-LEECH INJECTOR", "secondary_weapon": "BUTCHER'S SAW", "ability_name": "COAGULATE", "style": "Ember pressure, recovery windows, and sawback counters.", "move_speed": 5.0, "max_vitality": 104, "primary_damage": 27, "ability_damage": 52, "ability_range": 3.5, "ability_speed": 6.8, "ability_duration": 0.40, "cooldown": 5.9, "reload_duration": 0.49, "melee_duration": 0.57},
	"iron-revenant": {"label": "IRON REVENANT", "callsign": "SIEGE", "accent": Color("6D8A94"), "primary_weapon": "LEVIATHAN DECK CANNON", "secondary_weapon": "ANCHOR CHAIN GAUNTLET", "ability_name": "BALLAST STEP", "style": "Heavy cannon volleys and deliberate anchor-lane control.", "move_speed": 4.6, "max_vitality": 124, "primary_damage": 43, "ability_damage": 50, "ability_range": 4.2, "ability_speed": 6.6, "ability_duration": 0.34, "cooldown": 7.4, "reload_duration": 0.92, "melee_duration": 0.61},
}

static func normalized_id(value: String) -> String:
	return value if CLASS_IDS.has(value) else DEFAULT_CLASS_ID

static func profile(class_id: String) -> Dictionary:
	return (PROFILES.get(normalized_id(class_id), PROFILES[DEFAULT_CLASS_ID]) as Dictionary).duplicate(true)

static func selected_class_id() -> String:
	var config := ConfigFile.new()
	if config.load(SELECTION_PATH) != OK:
		return DEFAULT_CLASS_ID
	return normalized_id(str(config.get_value("class", "id", DEFAULT_CLASS_ID)))

static func save_selected_class(class_id: String) -> String:
	var normalized := normalized_id(class_id)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall"))
	var config := ConfigFile.new()
	config.set_value("class", "id", normalized)
	config.save(SELECTION_PATH)
	return normalized
