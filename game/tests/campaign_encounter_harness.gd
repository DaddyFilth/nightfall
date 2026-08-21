extends SceneTree

const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const HollowedActor = preload("res://scripts/presentation/hollowed_actor.gd")
const ObservatoryConductor = preload("res://scripts/gameplay/observatory_conductor.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var archetypes: Dictionary = {}
	for level_id in range(1, 11):
		var boss: Dictionary = CampaignRoster.boss_profile(level_id)
		var traversal: Dictionary = CampaignRoster.traversal_profile(level_id)
		var puzzle: Dictionary = CampaignRoster.puzzle_profile(level_id)
		_assert(str(boss.get("title", "")).length() > 0 and int(boss.get("vitality", 0)) >= 360, "boss_profile_%02d" % level_id)
		_assert((boss.get("attacks", []) as Array).size() == 3, "boss_attacks_%02d" % level_id)
		_assert(str(traversal.get("mode", "")).length() > 0, "traversal_%02d" % level_id)
		var puzzle_mode := str(puzzle.get("mode", ""))
		var valid_puzzle := false
		if puzzle_mode == "sequence":
			valid_puzzle = (puzzle.get("sequence", []) as Array).size() == 3
		elif puzzle_mode == "route":
			valid_puzzle = int(puzzle.get("correctIndex", -1)) >= 0 and int(puzzle.get("correctIndex", -1)) <= 2
		elif puzzle_mode == "charge":
			valid_puzzle = int(puzzle.get("anchorIndex", -1)) >= 0 and int(puzzle.get("hitsRequired", 0)) >= 3
		elif puzzle_mode == "binary":
			valid_puzzle = (puzzle.get("requiredSet", []) as Array).size() >= 2
		_assert(valid_puzzle, "puzzle_%02d" % level_id)
		for index in CampaignRoster.encounter_size(level_id):
			archetypes[CampaignRoster.enemy_archetype(level_id, index)] = true
	_assert(archetypes.has("iron_abbot") and archetypes.has("lantern_wisp") and archetypes.has("leviathan_guard"), "late_game_archetypes_authored")
	var actor := HollowedActor.new()
	actor.configure_archetype("leviathan_guard")
	root.add_child(actor)
	await process_frame
	_assert(actor.archetype_label == "LEVIATHAN GUARD" and actor.health == 190 and actor.attack_damage == 22 and actor.body_scale > 1.3, "heavy_archetype_tuned")
	actor.queue_free()
	var boss_actor := ObservatoryConductor.new()
	boss_actor.configure_campaign_profile(CampaignRoster.boss_profile(10))
	root.add_child(boss_actor)
	await process_frame
	_assert(boss_actor.boss_title == "BRASS LEVIATHAN" and boss_actor.max_vitality == 820 and boss_actor.attack_name() == "CROWN BREAK", "mission_boss_configured")
	print("CAMPAIGN_ENCOUNTER_PASS bosses=named traversal=authored archetypes=late_game")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("CAMPAIGN_ENCOUNTER_FAIL " + label)
		quit(1)
