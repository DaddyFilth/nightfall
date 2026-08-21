extends SceneTree

const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const StoryProgress = preload("res://scripts/gameplay/story_campaign_progress.gd")
const SCENE_PATHS := [
	"res://scenes/brasswake_combat.tscn",
	"res://scenes/the_broken_compass.tscn",
	"res://scenes/the_observatory_campaign.tscn",
	"res://scenes/sable_wake.tscn",
	"res://scenes/lanterns_of_the_lost.tscn",
	"res://scenes/iron_cathedral.tscn",
	"res://scenes/coffin_fleet.tscn",
	"res://scenes/the_thirteenth_bell.tscn",
	"res://scenes/red_meridian.tscn",
	"res://scenes/blood_and_brass_finale.tscn"
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert(CampaignRoster.level_count() == 10, "ten_levels_authored")
	for level_id in range(1, 11):
		var checkpoint_count := CampaignRoster.checkpoint_count(level_id)
		var encounter_size := CampaignRoster.encounter_size(level_id)
		_assert(checkpoint_count >= 3 and checkpoint_count <= 6, "checkpoint_count_%02d" % level_id)
		_assert(encounter_size >= 3 and encounter_size <= 6, "encounter_size_%02d" % level_id)
		_assert(StoryProgress.can_start_from_defeated(level_id, level_id - 1), "sequential_unlock_%02d" % level_id)
		if level_id > 1:
			_assert(not StoryProgress.can_start_from_defeated(level_id, level_id - 2), "sequential_lock_%02d" % level_id)
		var scene := load(SCENE_PATHS[level_id - 1]) as PackedScene
		_assert(scene != null, "scene_load_%02d" % level_id)
		var mission := scene.instantiate()
		root.add_child(mission)
		await process_frame
		_assert(mission.story_mission_id == level_id, "scene_level_id_%02d" % level_id)
		_assert(mission.campaign_checkpoint_count == checkpoint_count, "scene_checkpoint_count_%02d" % level_id)
		_assert(mission.enemies.size() == encounter_size, "scene_encounter_size_%02d" % level_id)
		_assert(mission.get_node_or_null("NightfallPlayer/FirstPersonPitchPivot/FirstPersonCamera") != null, "fps_camera_%02d" % level_id)
		_assert(mission.get_node_or_null("LevelSignature_%02d" % level_id) != null, "animated_signature_%02d" % level_id)
		mission.queue_free()
		await process_frame
	print("CAMPAIGN_ROSTER_PASS levels=10 checkpoints=3_to_6 scenes=fps sequential=locked")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("CAMPAIGN_ROSTER_FAIL " + label)
		quit(1)
