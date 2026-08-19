## GameData.gd  –  autoload singleton
## Holds level descriptors, storyline beats, palette constants, and the
## player's current game-type / difficulty selection.
extends Node

# ── Palette (shared across all scripts) ─────────────────────────────────────
const COLOR_BG     := Color(0.04, 0.04, 0.14, 1.0)
const COLOR_ACCENT := Color(0.55, 0.35, 1.00, 1.0)
const COLOR_GOLD   := Color(1.00, 0.80, 0.20, 1.0)
const COLOR_CARD   := Color(0.10, 0.08, 0.22, 0.92)
const COLOR_STAR   := Color(0.85, 0.85, 1.00, 0.80)
const COLOR_DANGER := Color(1.00, 0.30, 0.30, 1.0)
const COLOR_CYAN   := Color(0.20, 0.90, 0.95, 1.0)

# ── Game-type constants ───────────────────────────────────────────────────────
enum GameType { STORY, ENDLESS, TIME_ATTACK }
const GAME_TYPE_LABELS := ["Story", "Endless", "Time Attack"]

# ── Difficulty constants ──────────────────────────────────────────────────────
enum Difficulty { EASY, NORMAL, HARD }
const DIFFICULTY_LABELS := ["Easy", "Normal", "Hard"]

# Multipliers applied to taps_needed for each difficulty.
# Easy   = 0.6×  (fewer taps required)
# Normal = 1.0×  (vanilla)
# Hard   = 1.6×  (more taps required)
const DIFFICULTY_TAP_MULT := [0.6, 1.0, 1.6]

# Multipliers applied to star_speed for each difficulty.
const DIFFICULTY_SPEED_MULT := [0.8, 1.0, 1.3]

# ── Active session settings (written by StartMenu, read by LevelManager) ──────
var selected_game_type: int = GameType.STORY
var selected_difficulty: int = Difficulty.NORMAL

# ── Level descriptor structure ───────────────────────────────────────────────
# Each entry:
#   id          int     – 1-based level number
#   title       String  – shown in the level banner
#   bg_color    Color   – background sky colour for this level
#   star_speed  float   – multiplier on star fall speed
#   taps_needed int     – taps required to complete level
#   story_pre   String  – narrative shown BEFORE the level starts
#   story_post  String  – narrative shown AFTER the level ends
#   music_pitch float   – pitch shift applied to the procedural music loop
#   danger_at   int     – taps remaining when "danger" audio kicks in (0 = off)

const LEVELS: Array = [
	{
		"id": 1,
		"title": "The First Light",
		"bg_color": Color(0.04, 0.04, 0.14),
		"star_speed": 1.0,
		"taps_needed": 10,
		"story_pre":  "Long before the dawn, a single spark drifted through the\nvoid. You are that spark.\n\nTap to ignite the Nightfall.",
		"story_post": "The darkness stirs. Something ancient notices your light.",
		"music_pitch": 1.0,
		"danger_at": 0,
	},
	{
		"id": 2,
		"title": "Echoes in the Dark",
		"bg_color": Color(0.05, 0.03, 0.18),
		"star_speed": 1.3,
		"taps_needed": 20,
		"story_pre":  "Whispers ripple outward from your glow.\nShapes form at the edge of sight — curious, not yet hostile.\n\nKeep the flame alive.",
		"story_post": "The echoes have a name now. They call it the Veil.",
		"music_pitch": 1.1,
		"danger_at": 5,
	},
	{
		"id": 3,
		"title": "The Veil Descends",
		"bg_color": Color(0.08, 0.03, 0.20),
		"star_speed": 1.7,
		"taps_needed": 30,
		"story_pre":  "The Veil wraps itself around the sky.\nStars begin to wink out one by one.\n\nYour light is all that remains.",
		"story_post": "One star survives — yours. It pulses with something new: hope.",
		"music_pitch": 1.2,
		"danger_at": 8,
	},
	{
		"id": 4,
		"title": "Heart of Darkness",
		"bg_color": Color(0.10, 0.02, 0.15),
		"star_speed": 2.2,
		"taps_needed": 40,
		"story_pre":  "At the centre of the Veil lies the Obsidian Core.\nTo pierce it you must outshine the void itself.\n\nDo not falter.",
		"story_post": "A crack appears in the Core. Light bleeds through.",
		"music_pitch": 1.35,
		"danger_at": 10,
	},
	{
		"id": 5,
		"title": "Nightfall Breaks",
		"bg_color": Color(0.06, 0.06, 0.22),
		"star_speed": 2.8,
		"taps_needed": 50,
		"story_pre":  "The sky remembers what light feels like.\nEvery tap sends a ripple across creation.\n\nThis is the final night — make it shine.",
		"story_post": "Dawn breaks for the first time in an age.\nYou did not just survive the Nightfall —\nyou became it.",
		"music_pitch": 1.5,
		"danger_at": 12,
	},
]

func get_level(index: int) -> Dictionary:
	if index < LEVELS.size():
		var entry: Dictionary = LEVELS[index].duplicate()
		return _apply_difficulty(entry)
	# Endless mode: repeat last entry with escalating difficulty
	var base: Dictionary = LEVELS[LEVELS.size() - 1].duplicate()
	var extra := index - LEVELS.size() + 1
	base["id"]          = index + 1
	base["title"]       = "Night %d" % (index + 1)
	base["taps_needed"] = 50 + extra * 15
	base["star_speed"]  = 2.8 + extra * 0.4
	base["music_pitch"] = minf(1.5 + extra * 0.05, 2.0)
	base["danger_at"]   = 12 + extra * 2
	base["story_pre"]   = "The darkness deepens.\nLevel %d — keep the light burning." % (index + 1)
	base["story_post"]  = "Another night conquered.\nThe flame endures."
	return _apply_difficulty(base)

func _apply_difficulty(data: Dictionary) -> Dictionary:
	var d := selected_difficulty
	data["taps_needed"] = max(1, int(data["taps_needed"] * DIFFICULTY_TAP_MULT[d]))
	data["star_speed"]  = data["star_speed"] * DIFFICULTY_SPEED_MULT[d]
	return data
