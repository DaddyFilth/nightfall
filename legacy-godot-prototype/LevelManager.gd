## LevelManager.gd  –  autoload singleton
## Tracks the active level, emits signals as level state changes.
## Supports Story, Endless, and Time Attack game types.
extends Node

signal level_started(level_data: Dictionary)
signal level_completed(level_data: Dictionary)
signal danger_triggered(taps_left: int)

var current_index: int = 0
var current_data:  Dictionary = {}
var taps_this_level: int = 0

# ── Time Attack state ─────────────────────────────────────────────────────────
const TIME_ATTACK_SECONDS := 30.0
var time_attack_remaining: float = TIME_ATTACK_SECONDS
var _time_attack_active: bool = false

func _ready() -> void:
	current_data = GameData.get_level(current_index)

# Reset the manager when a new game starts from the start menu.
func reset() -> void:
	current_index   = 0
	taps_this_level = 0
	_time_attack_active = false
	time_attack_remaining = TIME_ATTACK_SECONDS
	current_data = GameData.get_level(current_index)

# Call once the pre-level story has been dismissed.
func begin_level() -> void:
	taps_this_level = 0
	_time_attack_active = (GameData.selected_game_type == GameData.GameType.TIME_ATTACK)
	time_attack_remaining = TIME_ATTACK_SECONDS
	emit_signal("level_started", current_data)

# Call on every player tap.  Returns true when the level is now complete.
func register_tap() -> bool:
	taps_this_level += 1
	var needed: int  = current_data.get("taps_needed", 10)
	var danger_at: int = current_data.get("danger_at", 0)
	var remaining := needed - taps_this_level

	if danger_at > 0 and remaining == danger_at:
		emit_signal("danger_triggered", remaining)

	if taps_this_level >= needed:
		emit_signal("level_completed", current_data)
		return true
	return false

# Advance to the next level; returns the new level data.
func advance() -> Dictionary:
	current_index += 1
	current_data   = GameData.get_level(current_index)
	taps_this_level = 0
	return current_data

func progress_ratio() -> float:
	if _time_attack_active:
		# In Time Attack, progress bar reflects time elapsed.
		return clampf(1.0 - time_attack_remaining / TIME_ATTACK_SECONDS, 0.0, 1.0)
	var needed: int = current_data.get("taps_needed", 1)
	return clampf(float(taps_this_level) / float(needed), 0.0, 1.0)

func _process(delta: float) -> void:
	if not _time_attack_active:
		return
	time_attack_remaining -= delta
	if time_attack_remaining <= 0.0:
		time_attack_remaining = 0.0
		_time_attack_active   = false
		emit_signal("level_completed", current_data)
