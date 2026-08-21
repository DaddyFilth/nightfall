extends SceneTree

const CombatScene = preload("res://scenes/brasswake_combat.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var combat := CombatScene.instantiate()
	root.add_child(combat)
	await process_frame
	await process_frame
	var player_exists := combat.get_node_or_null("NightfallPlayer/BloodwakeCaptainVisual") != null
	var hud_exists := combat.get_node_or_null("BrasswakeCombatHUD/CaptainStatusFrame/CaptainVitalityBar") != null
	var fps_camera_exists := combat.get_node_or_null("NightfallPlayer/FirstPersonPitchPivot/FirstPersonCamera") != null
	var viewmodel_exists := combat.get_node_or_null("NightfallPlayer/FirstPersonPitchPivot/FirstPersonCamera/BloodwakeViewmodel/WheelLockAnimationRig") != null
	var reticle_exists := combat.get_node_or_null("BrasswakeCombatHUD/FirstPersonReticle") != null
	var touch_exists := combat.get_node_or_null("TouchControls") != null
	var resolution_exists := combat.get_node_or_null("BrasswakeCombatHUD/MissionResolutionFrame/MissionResolutionLabel") != null
	var export_button_exists := combat.get_node_or_null("BrasswakeCombatHUD/MissionResolutionFrame/ExportCompletionRecordButton") != null
	var puzzle_gate: Node = combat.get("active_puzzle_gate") as Node
	var puzzle_exists := puzzle_gate != null and puzzle_gate.get_node_or_null("PuzzleRune_0") != null
	if puzzle_gate:
		var sequence: Array = puzzle_gate.get("sequence")
		var rune_positions: Array = puzzle_gate.get("rune_positions")
		for rune_index in sequence:
			puzzle_gate.call("take_projectile_hit", 25, rune_positions[int(rune_index)])
	await process_frame
	var checkpoint_exists := combat.get_node_or_null("CampaignCheckpoint_01_01") != null
	var campaign_checkpoint_count: int = combat.campaign_checkpoint_count
	combat.active_checkpoint_index = campaign_checkpoint_count
	combat.checkpoints_complete = true
	var enemies := combat.get_tree().get_nodes_in_group("nightfall_enemy")
	for enemy in enemies:
		for _hit in 4:
			enemy.call("take_projectile_hit", 25, Vector3.ZERO)
	await process_frame
	var boss_exists := combat.get_node_or_null("DrownedAdmiral") != null
	var boss_hud_exists := combat.get_node_or_null("BrasswakeCombatHUD/DrownedAdmiralHUD/DrownedAdmiralVitalityBar") != null
	var landscape_configured: bool = combat.is_landscape_runtime()
	if player_exists and hud_exists and fps_camera_exists and viewmodel_exists and reticle_exists and touch_exists and resolution_exists and export_button_exists and puzzle_exists and checkpoint_exists and campaign_checkpoint_count == 3 and enemies.size() == 4 and boss_exists and boss_hud_exists and landscape_configured:
		print("GAMEPLAY_SCENE_PASS landscape=true fps=true viewmodel=true puzzle=ordered checkpoints=3 enemies=4 boss=true hud=true touch=true export=true")
		quit(0)
		return
	printerr("GAMEPLAY_SCENE_FAIL player=%s hud=%s fps=%s viewmodel=%s reticle=%s touch=%s resolution=%s export=%s puzzle=%s checkpoint=%s checkpoint_count=%s enemies=%s boss=%s boss_hud=%s landscape=%s" % [player_exists, hud_exists, fps_camera_exists, viewmodel_exists, reticle_exists, touch_exists, resolution_exists, export_button_exists, puzzle_exists, checkpoint_exists, campaign_checkpoint_count, enemies.size(), boss_exists, boss_hud_exists, landscape_configured])
	quit(1)
