class_name StoryCampaignProgress
extends RefCounted

## Native story progression remains device-local. A mission can only start when the
## immediately preceding mission has been defeated and recorded in this ledger.
const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const SAVE_PATH := "user://blood_brass_story_progress.cfg"
const SECTION := "story"
const DEFEATED_THROUGH_KEY := "defeated_through"
const CHECKPOINTS_KEY := "checkpoint_progress"

static func defeated_through() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 0
	return clampi(int(config.get_value(SECTION, DEFEATED_THROUGH_KEY, 0)), 0, CampaignRoster.level_count())

static func can_start(mission_number: int) -> bool:
	return can_start_from_defeated(mission_number, defeated_through())

static func can_start_from_defeated(mission_number: int, defeated_mission: int) -> bool:
	if not CampaignRoster.is_valid_level(mission_number):
		return false
	if mission_number == 1:
		return true
	return mission_number <= max(0, defeated_mission) + 1

static func checkpoint_reached(mission_number: int) -> int:
	if not CampaignRoster.is_valid_level(mission_number):
		return 0
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 0
	var progress: Dictionary = config.get_value(SECTION, CHECKPOINTS_KEY, {})
	return clampi(int(progress.get(str(mission_number), 0)), 0, CampaignRoster.checkpoint_count(mission_number))

static func record_checkpoint(mission_number: int, checkpoint_index: int) -> bool:
	if not can_start(mission_number):
		return false
	var maximum := CampaignRoster.checkpoint_count(mission_number)
	if checkpoint_index < 1 or checkpoint_index > maximum:
		return false
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	var progress: Dictionary = config.get_value(SECTION, CHECKPOINTS_KEY, {})
	var current := clampi(int(progress.get(str(mission_number), 0)), 0, maximum)
	progress[str(mission_number)] = max(current, checkpoint_index)
	config.set_value(SECTION, CHECKPOINTS_KEY, progress)
	config.save(SAVE_PATH)
	return true

static func record_defeat(mission_number: int) -> void:
	if mission_number <= 0:
		return
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	var current := clampi(int(config.get_value(SECTION, DEFEATED_THROUGH_KEY, 0)), 0, CampaignRoster.level_count())
	var valid_mission := clampi(mission_number, 1, CampaignRoster.level_count())
	var progress: Dictionary = config.get_value(SECTION, CHECKPOINTS_KEY, {})
	progress[str(valid_mission)] = CampaignRoster.checkpoint_count(valid_mission)
	config.set_value(SECTION, CHECKPOINTS_KEY, progress)
	config.set_value(SECTION, DEFEATED_THROUGH_KEY, max(current, valid_mission))
	config.save(SAVE_PATH)
