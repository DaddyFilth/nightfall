extends "res://scripts/presentation/procedural_station_arena.gd"

const ObservatoryConductor = preload("res://scripts/gameplay/observatory_conductor.gd")
const StoryProgress = preload("res://scripts/gameplay/story_campaign_progress.gd")
const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const FpsCampaignCheckpoint = preload("res://scripts/gameplay/fps_campaign_checkpoint.gd")
const CampaignTraversalSetPiece = preload("res://scripts/gameplay/campaign_traversal_set_piece.gd")
const CampaignPuzzleGate = preload("res://scripts/gameplay/campaign_puzzle_gate.gd")
const CampaignCompletionRecord = preload("res://scripts/integration/campaign_completion_record.gd")
const CampaignBossHazard = preload("res://scripts/gameplay/campaign_boss_hazard.gd")

const VEIL_COOLDOWN_SECONDS := 6.0
const PRIVATEER_HIT_DISTANCE := 1.55

@export_range(1, 10, 1) var story_mission_id := 1
var player: NightfallPlayer
var enemies: Array[HollowedActor] = []
var conductor: ObservatoryConductor
var kills := 0
var boss_active := false
var mission_finished := false
var victory := false
var veil_cooldown_remaining := 0.0
var boss_attack_remaining := 2.6
var status_message := "CLEAR THE WHARF // SELECTED CLASS LOADOUT READY"
var status_message_remaining := 6.0

var player_vitality_label: Label
var player_vitality_bar: ProgressBar
var veil_label: Label
var kill_label: Label
var objective_label: Label
var boss_frame: ColorRect
var boss_label: Label
var boss_bar: ProgressBar
var boss_status_label: Label
var end_frame: ColorRect
var end_label: Label
var camera: Camera3D
var fps_reticle: Label
var fps_options_toggle: Button
var fps_options_panel: ColorRect
var fps_sensitivity_slider: HSlider
var fps_sensitivity_value: Label
var fps_invert_toggle: Button
var threat_indicator: Label
var active_threat: Node3D
var active_threat_text := ""
var threat_remaining := 0.0
var campaign_title := ""
var campaign_checkpoint_count := 0
var active_checkpoint_index := 0
var checkpoints_complete := false
var mission_locked := false
var active_checkpoint: FpsCampaignCheckpoint
var active_puzzle_gate: CampaignPuzzleGate
var level_signature_rig: Node3D
var level_signature_pylons: Array[MeshInstance3D] = []
var level_signature_phase := 0.0
var traversal_set_piece: CampaignTraversalSetPiece
var active_boss_profile: Dictionary = {}
var boss_hazard: CampaignBossHazard

func _ready() -> void:
	super._ready()
	_enforce_landscape_orientation()
	player = get_node_or_null("NightfallPlayer") as NightfallPlayer
	var presentation_camera := get_node_or_null("PresentationCamera") as Camera3D
	camera = player.get_fps_camera() if is_instance_valid(player) else presentation_camera
	if is_instance_valid(presentation_camera) and presentation_camera != camera:
		presentation_camera.current = false
	_collect_privateers()
	_build_combat_hud()
	_configure_campaign_level()
	_build_level_signature()
	_build_traversal_set_piece()
	if player:
		status_message = "%s // %s READY" % [player.class_callsign(), player.class_primary_weapon()]
		player.ability_requested.connect(_on_veil_requested)
		player.enemy_hit_resolved.connect(_on_player_hit)
		player.fire_requested.connect(_restart_after_resolution)
		player.aim_preferences_changed.connect(_sync_fps_options)
		player.reload_started.connect(_on_reload_started)
		player.reload_finished.connect(_on_reload_finished)
	if mission_locked:
		_show_locked_campaign_message()
	else:
		_build_next_checkpoint()
	_update_combat_hud()

func _process(delta: float) -> void:
	super._process(delta)
	_update_level_signature(delta)
	if not player:
		return
	if mission_locked:
		return
	_update_follow_camera(delta)
	if veil_cooldown_remaining > 0.0:
		veil_cooldown_remaining = maxf(0.0, veil_cooldown_remaining - delta)
	if status_message_remaining > 0.0:
		status_message_remaining = maxf(0.0, status_message_remaining - delta)
	_update_directional_threat(delta)
	if not mission_finished:
		_drive_privateer_threats(delta)
		_drive_drowned_admiral(delta)
		if player.vitality <= 0:
			_finish_mission(false)
	_update_combat_hud()

func is_landscape_runtime() -> bool:
	return int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) == DisplayServer.SCREEN_LANDSCAPE

func _enforce_landscape_orientation() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)

func _collect_privateers() -> void:
	for node in get_tree().get_nodes_in_group("nightfall_enemy"):
		if node is HollowedActor:
			var actor := node as HollowedActor
			enemies.append(actor)
			actor.state_changed.connect(_on_enemy_state.bind(actor))

func _drive_privateer_threats(delta: float) -> void:
	if not is_instance_valid(player):
		return
	for actor in enemies:
		if not is_instance_valid(actor) or actor.defeated:
			continue
		var to_player := player.global_position - actor.global_position
		to_player.y = 0.0
		var distance := to_player.length()
		if distance > actor.attack_range and distance > 0.01:
			actor.global_position += to_player.normalized() * delta * actor.movement_speed
			actor.look_at(player.global_position, Vector3.UP, true)
		var state := actor.animation_state_name()
		if state == "attack" and distance <= actor.attack_range and actor.state_elapsed >= 0.27 and not actor.get_meta("attack_landed", false):
			actor.set_meta("attack_landed", true)
			player.take_enemy_hit(actor.attack_damage, actor.global_position, actor.attack_knockback)
			audio_layer.play_cue("impact_target")
		elif state != "attack" and actor.has_meta("attack_landed"):
			actor.remove_meta("attack_landed")

func _drive_drowned_admiral(delta: float) -> void:
	if not boss_active or not conductor or conductor.is_defeated:
		return
	boss_attack_remaining = maxf(0.0, boss_attack_remaining - delta)
	if boss_attack_remaining <= 0.0:
		conductor.trigger_attack()
		boss_attack_remaining = 3.2

func _on_enemy_state(state_name: String, actor: HollowedActor) -> void:
	if state_name == "attack" and not actor.defeated:
		_show_directional_threat(actor, "%s STRIKE" % actor.archetype_label)
		audio_layer.play_cue("enemy_attack")
		return
	if state_name != "dissolve" or actor.get_meta("kill_counted", false):
		return
	actor.set_meta("kill_counted", true)
	kills += 1
	_set_status("PRIVATEER SUNK // %s OF %s" % [kills, enemies.size()], 2.0)
	if kills >= enemies.size():
		_try_spawn_drowned_admiral()

func _on_veil_requested() -> void:
	if mission_finished:
		return
	if veil_cooldown_remaining > 0.0:
		_set_status("VEIL RECHARGING // %.1fs" % veil_cooldown_remaining, 1.0)
		return
	veil_cooldown_remaining = player.class_cooldown()
	var base_speed := float(player.class_profile.get("move_speed", 5.2))
	var ability_duration := player.class_ability_duration()
	player.move_speed = player.class_ability_speed()
	get_tree().create_timer(ability_duration).timeout.connect(func() -> void:
		if player and not mission_finished:
			player.move_speed = base_speed
	)
	var target := _nearest_damage_target(player.global_position)
	if target and player.global_position.distance_to(target.global_position) <= player.class_ability_range():
		var result: Dictionary = target.get_meta("nightfall_damage_target").take_projectile_hit(player.class_ability_damage(), player.global_position)
		_process_damage_result(result)
		_set_status("%s // %s" % [player.class_ability_name(), player.class_callsign()], 1.35)
	else:
		_set_status("%s // CLOSE THE DISTANCE" % player.class_ability_name(), 1.35)

func _fire_projectile(origin: Vector3, direction: Vector3) -> void:
	if mission_finished:
		return
	audio_layer.play_cue("projectile_fire")
	var projectile := NightfallProjectile.new()
	add_child(projectile)
	projectile.damage = player.primary_projectile_damage() if player else projectile.damage
	projectile.fire(origin, direction)
	var result: Dictionary = projectile.resolve_segment(22.0)
	if result["kind"] == "target":
		audio_layer.play_cue("impact_target")
		_process_damage_result(result.get("result", {}))
	elif result["kind"] == "solid":
		audio_layer.play_cue("impact_solid")
	projectile.queue_free()

func _nearest_damage_target(origin: Vector3) -> Node3D:
	var nearest: Node3D
	var nearest_distance := INF
	for actor in enemies:
		if not is_instance_valid(actor) or actor.defeated:
			continue
		var hurtbox := actor.get_node_or_null("HollowedHurtbox") as Node3D
		if hurtbox and origin.distance_to(hurtbox.global_position) < nearest_distance:
			nearest = hurtbox
			nearest_distance = origin.distance_to(hurtbox.global_position)
	if boss_active and conductor and not conductor.is_defeated and conductor.hurtbox:
		if origin.distance_to(conductor.hurtbox.global_position) < nearest_distance:
			nearest = conductor.hurtbox
	return nearest

func _process_damage_result(result: Dictionary) -> void:
	if not result.get("accepted", false):
		return
	if result.get("reason", "") == "defeated" and boss_active:
		_finish_mission(true)

func _spawn_drowned_admiral() -> void:
	if boss_active or mission_finished:
		return
	boss_active = true
	conductor = ObservatoryConductor.new()
	active_boss_profile = CampaignRoster.boss_profile(story_mission_id)
	conductor.configure_campaign_profile(active_boss_profile)
	conductor.configure_branch("last_platform")
	conductor.position = Vector3(0, 0, 1.15)
	conductor.track_player(player)
	conductor.vitality_changed.connect(_update_boss_hud)
	conductor.attack_windup_started.connect(_on_boss_windup)
	conductor.attack_resolved.connect(_on_boss_attack_resolved)
	conductor.defeated.connect(func(_reward: Dictionary) -> void: _finish_mission(true))
	add_child(conductor)
	boss_hazard = CampaignBossHazard.new()
	boss_hazard.configure(CampaignRoster.hazard_profile(story_mission_id))
	boss_hazard.track_player(player)
	boss_hazard.windup_started.connect(_on_boss_hazard_windup)
	boss_hazard.resolved.connect(_on_boss_hazard_resolved)
	add_child(boss_hazard)
	boss_hazard.set_active(true)
	conductor.name = "DrownedAdmiral" if story_mission_id == 1 else "MissionBoss_%02d" % story_mission_id
	_set_status("%s BOARDS // DODGE THE TELEGRAPH" % str(active_boss_profile.get("title", "MISSION BOSS")), 4.0)
	_update_boss_hud(conductor.vitality, conductor.max_vitality, conductor.phase)

func _on_boss_windup(attack_name: String, _duration: float, _phase: int) -> void:
	_set_status("INCOMING // %s // DODGE" % attack_name, 1.2)
	_show_directional_threat(conductor, "ADMIRAL // %s" % attack_name, 1.15)
	audio_layer.play_cue("enemy_attack")

func _on_boss_attack_resolved(_results: Array[Dictionary]) -> void:
	_set_status("ADMIRAL STRIKE RESOLVED // RETURN FIRE", 1.1)

func _on_boss_hazard_windup(hazard_name: String, _duration: float) -> void:
	_set_status("ARENA HAZARD // %s // MOVE" % hazard_name, 1.0)
	_show_directional_threat(boss_hazard, "HAZARD // %s" % hazard_name, 1.05)
	audio_layer.play_cue("enemy_attack")

func _on_boss_hazard_resolved(hazard_name: String, hits: int) -> void:
	_set_status("%s RESOLVED // %s ZONE%s HIT" % [hazard_name, hits, "S" if hits != 1 else ""], 0.9)

func _on_player_hit(_amount: int, dodged: bool, _vitality_remaining: int) -> void:
	if dodged:
		_set_status("DODGE WINDOW // CLEAN ESCAPE", 0.9)

func _on_reload_started() -> void:
	audio_layer.play_cue("wheel_lock_reload")
	_set_status("WHEEL-LOCK RELOADING // HOLD FIRE TO AIM", 0.7)

func _on_reload_finished() -> void:
	_set_status("WHEEL-LOCK READY // RETURN FIRE", 0.8)

func _restart_after_resolution(_origin: Vector3, _direction: Vector3) -> void:
	if mission_finished:
		get_tree().reload_current_scene()

func _finish_mission(did_win: bool) -> void:
	if mission_finished:
		return
	mission_finished = true
	victory = did_win
	if is_instance_valid(boss_hazard):
		boss_hazard.set_active(false)
	if did_win:
		StoryProgress.record_defeat(story_mission_id)
		CampaignCompletionRecord.record_victory(story_mission_id, campaign_title, StoryProgress.defeated_through())
		var next_title := CampaignRoster.level_title(story_mission_id + 1)
		var completion_text := "CAMPAIGN COMPLETE" if next_title.is_empty() else "LEVEL %02d UNLOCKED // %s" % [story_mission_id + 1, next_title]
		_set_status("LEVEL %02d DEFEATED // %s" % [story_mission_id, completion_text], 99.0)
		end_label.text = "%s CLEARED\nLEVEL %02d DEFEATED\n%s\n\nTAP FIRE TO REPLAY" % [campaign_title, story_mission_id, completion_text]
	else:
		_set_status("THE TIDE CLAIMS THE CAPTAIN", 99.0)
		end_label.text = "BLOODWAKE SUNK\nTHE WHARF HOLDS\n\nTAP FIRE TO REPLAY"
	end_frame.visible = true
	end_label.visible = true

func _set_status(value: String, duration: float) -> void:
	status_message = value
	status_message_remaining = duration

func _build_combat_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "BrasswakeCombatHUD"
	add_child(layer)
	var player_frame := _hud_frame(Vector2(24, 20), Vector2(356, 80))
	player_frame.name = "CaptainStatusFrame"
	layer.add_child(player_frame)
	player_vitality_label = _hud_label("DUELIST // VITALITY", Vector2(14, 10), 13, Color("F5F0E9"))
	player_frame.add_child(player_vitality_label)
	player_vitality_bar = ProgressBar.new()
	player_vitality_bar.name = "CaptainVitalityBar"
	player_vitality_bar.position = Vector2(14, 31)
	player_vitality_bar.size = Vector2(328, 13)
	player_vitality_bar.min_value = 0
	player_vitality_bar.max_value = 100
	player_vitality_bar.show_percentage = false
	player_vitality_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_frame.add_child(player_vitality_bar)
	veil_label = _hud_label("ABILITY // READY", Vector2(14, 54), 10, Color("B8A4FF"))
	player_frame.add_child(veil_label)
	kill_label = _hud_label("WHARF // 0 / 4", Vector2(222, 54), 10, Color("E7CB63"))
	player_frame.add_child(kill_label)
	objective_label = _hud_label("CLEAR THE WHARF", Vector2(430, 24), 14, Color("EDE1C4"))
	layer.add_child(objective_label)
	var status_frame := _hud_frame(Vector2(430, 48), Vector2(420, 34))
	status_frame.name = "CombatObjectiveFrame"
	layer.add_child(status_frame)
	boss_status_label = _hud_label(status_message, Vector2(12, 9), 10, Color("C8BBA1"))
	status_frame.add_child(boss_status_label)
	boss_frame = _hud_frame(Vector2(886, 20), Vector2(370, 60))
	boss_frame.name = "DrownedAdmiralHUD"
	boss_frame.visible = false
	layer.add_child(boss_frame)
	boss_label = _hud_label("DROWNED ADMIRAL // 360 / 360", Vector2(14, 9), 11, Color("F5F0E9"))
	boss_frame.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.name = "DrownedAdmiralVitalityBar"
	boss_bar.position = Vector2(14, 30)
	boss_bar.size = Vector2(342, 13)
	boss_bar.min_value = 0
	boss_bar.max_value = 360
	boss_bar.value = 360
	boss_bar.show_percentage = false
	boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_frame.add_child(boss_bar)
	end_frame = _hud_frame(Vector2(400, 238), Vector2(480, 230))
	end_frame.name = "MissionResolutionFrame"
	end_frame.visible = false
	layer.add_child(end_frame)
	end_label = _hud_label("", Vector2(18, 32), 24, Color("F6E8CF"))
	end_label.name = "MissionResolutionLabel"
	end_label.size = Vector2(444, 138)
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_label.visible = false
	end_frame.add_child(end_label)
	var return_button := Button.new()
	return_button.name = "ReturnCampaignButton"
	return_button.text = "RETURN TO CAMPAIGN ROSTER"
	var export_button := Button.new()
	export_button.name = "ExportCompletionRecordButton"
	export_button.text = "EXPORT COMPLETION RECORD"
	export_button.position = Vector2(122, 148)
	export_button.size = Vector2(236, 28)
	export_button.add_theme_font_size_override("font_size", 10)
	export_button.pressed.connect(_export_completion_record)
	end_frame.add_child(export_button)
	return_button.position = Vector2(122, 182)
	return_button.size = Vector2(236, 34)
	return_button.add_theme_font_size_override("font_size", 11)
	return_button.pressed.connect(_return_to_campaign_hub)
	end_frame.add_child(return_button)
	fps_reticle = Label.new()
	fps_reticle.name = "FirstPersonReticle"
	fps_reticle.text = "+"
	fps_reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	fps_reticle.position = Vector2(-8, -15)
	fps_reticle.size = Vector2(16, 30)
	fps_reticle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fps_reticle.add_theme_font_size_override("font_size", 26)
	fps_reticle.add_theme_color_override("font_color", player.class_accent() if player else Color("D9F5EA"))
	fps_reticle.add_theme_color_override("font_outline_color", Color("071012"))
	fps_reticle.add_theme_constant_override("outline_size", 4)
	fps_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fps_reticle)
	threat_indicator = Label.new()
	threat_indicator.name = "DirectionalThreatIndicator"
	threat_indicator.size = Vector2(220, 34)
	threat_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	threat_indicator.add_theme_font_size_override("font_size", 14)
	threat_indicator.add_theme_color_override("font_color", Color("FFD1D9"))
	threat_indicator.add_theme_color_override("font_outline_color", Color("3A0A13"))
	threat_indicator.add_theme_constant_override("outline_size", 5)
	threat_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	threat_indicator.visible = false
	layer.add_child(threat_indicator)
	_build_fps_options_panel(layer)

func _configure_campaign_level() -> void:
	campaign_title = CampaignRoster.level_title(story_mission_id)
	active_boss_profile = CampaignRoster.boss_profile(story_mission_id)
	campaign_checkpoint_count = CampaignRoster.checkpoint_count(story_mission_id)
	active_checkpoint_index = StoryProgress.checkpoint_reached(story_mission_id)
	checkpoints_complete = active_checkpoint_index >= campaign_checkpoint_count
	mission_locked = not StoryProgress.can_start(story_mission_id)

func enemy_archetype_for_index(index: int) -> String:
	return CampaignRoster.enemy_archetype(story_mission_id, index)

func _build_traversal_set_piece() -> void:
	traversal_set_piece = CampaignTraversalSetPiece.new()
	traversal_set_piece.configure(CampaignRoster.traversal_profile(story_mission_id), _level_accent())
	traversal_set_piece.position = _checkpoint_position(mini(2, max(1, campaign_checkpoint_count))) + Vector3(0, 0.08, -2.0)
	add_child(traversal_set_piece)

func enemy_spawn_positions() -> Array[Vector3]:
	var base_positions: Array[Vector3] = [Vector3(-4.5, 0.1, -3.5), Vector3(4.5, 0.1, -5.2), Vector3(-2.8, 0.1, -8.0), Vector3(3.2, 0.1, -10.0), Vector3(-5.1, 0.1, -7.2), Vector3(5.1, 0.1, -9.1)]
	var positions: Array[Vector3] = []
	var rotation_angle := deg_to_rad(float((story_mission_id - 1) * 13))
	for index in CampaignRoster.encounter_size(story_mission_id):
		positions.append(base_positions[index].rotated(Vector3.UP, rotation_angle))
	return positions

func _level_accent() -> Color:
	var accents := [Color("D93056"), Color("B68A39"), Color("4A877A"), Color("5E79A6"), Color("E7CB63"), Color("8D2634"), Color("7A5C97"), Color("7F99A4"), Color("B24745"), Color("C7973A")]
	return accents[(story_mission_id - 1) % accents.size()]

func _build_level_signature() -> void:
	level_signature_rig = Node3D.new()
	level_signature_rig.name = "LevelSignature_%02d" % story_mission_id
	add_child(level_signature_rig)
	var accent := _level_accent()
	var base_angle := deg_to_rad(float((story_mission_id - 1) * 19))
	for index in range(3):
		var pylon := MeshInstance3D.new()
		pylon.name = "MissionPylon_%02d" % (index + 1)
		var mesh := PrismMesh.new()
		mesh.left_to_right = 0.82
		mesh.size = Vector3(0.92, 2.6 + float(index) * 0.36, 0.92)
		var material := StandardMaterial3D.new()
		material.albedo_color = accent.darkened(0.32)
		material.metallic = 0.72
		material.roughness = 0.24
		material.emission_enabled = true
		material.emission = accent
		material.emission_energy_multiplier = 1.15 + float(index) * 0.35
		mesh.material = material
		pylon.mesh = mesh
		var angle := base_angle + TAU * float(index) / 3.0
		pylon.position = Vector3(cos(angle) * 8.0, 1.35, -5.0 + sin(angle) * 3.8)
		level_signature_rig.add_child(pylon)
		level_signature_pylons.append(pylon)
	var beacon_light := OmniLight3D.new()
	beacon_light.name = "MissionSignatureLight"
	beacon_light.light_color = accent
	beacon_light.light_energy = 3.0
	beacon_light.omni_range = 11.0
	beacon_light.position = Vector3(0, 4.8, -5.0)
	level_signature_rig.add_child(beacon_light)
	var atmosphere := get_node_or_null("BrasswakeAtmosphere") as WorldEnvironment
	if atmosphere and atmosphere.environment:
		atmosphere.environment.fog_light_color = accent.darkened(0.42)

func _update_level_signature(delta: float) -> void:
	if not is_instance_valid(level_signature_rig):
		return
	level_signature_phase += delta
	level_signature_rig.rotation.y += delta * (0.08 + float(story_mission_id) * 0.004)
	for index in level_signature_pylons.size():
		var pylon := level_signature_pylons[index]
		if is_instance_valid(pylon):
			pylon.position.y = 1.35 + sin(level_signature_phase * 1.4 + float(index)) * 0.22
			pylon.rotation_degrees.y += delta * (16.0 + float(index) * 5.0)

func _show_locked_campaign_message() -> void:
	if player:
		player.set_physics_process(false)
	end_frame.visible = true
	end_label.visible = true
	end_label.text = "LEVEL %02d LOCKED\nCOMPLETE LEVEL %02d FIRST\n\nSEQUENTIAL CAMPAIGN REQUIRED" % [story_mission_id, max(1, story_mission_id - 1)]
	_set_status("LEVEL LOCKED // RETURN AFTER THE PRIOR MISSION", 99.0)

func _checkpoint_position(checkpoint_index: int) -> Vector3:
	var positions := [Vector3(-4.0, 0.0, 5.0), Vector3(4.2, 0.0, 2.4), Vector3(-3.0, 0.0, -1.6), Vector3(3.6, 0.0, -5.2), Vector3(-1.7, 0.0, -8.0), Vector3(1.0, 0.0, -10.2)]
	var base: Vector3 = positions[(checkpoint_index - 1) % positions.size()]
	var rotation_angle := float((story_mission_id - 1) * 17)
	return base.rotated(Vector3.UP, deg_to_rad(rotation_angle))

func _build_next_checkpoint() -> void:
	if campaign_checkpoint_count <= 0 or active_checkpoint_index >= campaign_checkpoint_count:
		checkpoints_complete = true
		_try_spawn_drowned_admiral()
		return
	var next_index := active_checkpoint_index + 1
	active_puzzle_gate = CampaignPuzzleGate.new()
	active_puzzle_gate.configure(story_mission_id, next_index, CampaignRoster.puzzle_profile(story_mission_id))
	active_puzzle_gate.position = _checkpoint_position(next_index) + Vector3(0, 0, -2.15)
	active_puzzle_gate.solved.connect(_on_puzzle_gate_solved)
	add_child(active_puzzle_gate)
	_set_status("CHECKPOINT %02d // SOLVE %s" % [next_index, str(CampaignRoster.puzzle_profile(story_mission_id).get("name", "ROUTE"))], 5.0)

func _on_puzzle_gate_solved(level_id: int, checkpoint_index: int) -> void:
	if level_id != story_mission_id or mission_locked:
		return
	_set_status("ROUTE SECURED // REACH CHECKPOINT %02d" % checkpoint_index, 3.2)
	audio_layer.play_cue("cinematic_transition")
	active_checkpoint = FpsCampaignCheckpoint.new()
	active_checkpoint.configure(story_mission_id, checkpoint_index, CampaignRoster.checkpoint_name(story_mission_id, checkpoint_index))
	active_checkpoint.position = _checkpoint_position(checkpoint_index)
	active_checkpoint.activated.connect(_on_campaign_checkpoint_activated)
	add_child(active_checkpoint)

func _on_campaign_checkpoint_activated(level_id: int, checkpoint_index: int) -> void:
	if level_id != story_mission_id or mission_locked:
		return
	active_checkpoint_index = checkpoint_index
	StoryProgress.record_checkpoint(story_mission_id, checkpoint_index)
	audio_layer.play_cue("cinematic_transition")
	if is_instance_valid(traversal_set_piece):
		traversal_set_piece.activate_checkpoint(checkpoint_index)
	if active_checkpoint_index >= campaign_checkpoint_count:
		checkpoints_complete = true
		_set_status("ALL CHECKPOINTS SECURED // CLEAR PRIVATEERS", 4.0)
		_try_spawn_drowned_admiral()
	else:
		_build_next_checkpoint()

func _try_spawn_drowned_admiral() -> void:
	if not checkpoints_complete or kills < enemies.size():
		return
	_spawn_drowned_admiral()

func _show_directional_threat(source: Node3D, message: String, duration: float = 0.82) -> void:
	if not is_instance_valid(source):
		return
	active_threat = source
	active_threat_text = message
	threat_remaining = maxf(threat_remaining, duration)

func _update_directional_threat(delta: float) -> void:
	if threat_remaining <= 0.0 or not is_instance_valid(active_threat) or not is_instance_valid(camera) or not threat_indicator:
		if threat_indicator:
			threat_indicator.visible = false
		return
	threat_remaining = maxf(0.0, threat_remaining - delta)
	var to_threat := active_threat.global_position - camera.global_position
	to_threat.y = 0.0
	if to_threat.length_squared() <= 0.001:
		return
	to_threat = to_threat.normalized()
	var right_strength := to_threat.dot(camera.global_transform.basis.x)
	var forward_strength := to_threat.dot(-camera.global_transform.basis.z)
	var arrow := "▲"
	var position_value := Vector2(530, 102)
	if absf(right_strength) > absf(forward_strength):
		arrow = "▶" if right_strength > 0.0 else "◀"
		position_value = Vector2(1035, 332) if right_strength > 0.0 else Vector2(24, 332)
	elif forward_strength < 0.0:
		arrow = "▼"
		position_value = Vector2(530, 646)
	threat_indicator.position = position_value
	threat_indicator.text = "%s %s" % [arrow, active_threat_text]
	threat_indicator.modulate.a = clampf(threat_remaining / 0.24, 0.0, 1.0)
	threat_indicator.visible = threat_remaining > 0.0

func _build_fps_options_panel(layer: CanvasLayer) -> void:
	fps_options_toggle = Button.new()
	fps_options_toggle.name = "FPSOptionsToggle"
	fps_options_toggle.text = "FPS OPTIONS"
	fps_options_toggle.position = Vector2(24, 116)
	fps_options_toggle.size = Vector2(164, 32)
	fps_options_toggle.add_theme_font_size_override("font_size", 11)
	fps_options_toggle.add_theme_color_override("font_color", Color("EDE1C4"))
	fps_options_toggle.pressed.connect(_toggle_fps_options)
	layer.add_child(fps_options_toggle)
	fps_options_panel = _hud_frame(Vector2(24, 156), Vector2(332, 176))
	fps_options_panel.name = "FPSOptionsPanel"
	fps_options_panel.visible = false
	fps_options_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(fps_options_panel)
	var title := _hud_label("FIRST-PERSON AIM", Vector2(14, 12), 14, Color("E7CB63"))
	fps_options_panel.add_child(title)
	var sensitivity_label := _hud_label("LOOK SENSITIVITY", Vector2(14, 47), 11, Color("F5F0E9"))
	fps_options_panel.add_child(sensitivity_label)
	fps_sensitivity_value = _hud_label("1.00x", Vector2(248, 47), 11, Color("9FCDD0"))
	fps_sensitivity_value.size = Vector2(66, 20)
	fps_sensitivity_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fps_options_panel.add_child(fps_sensitivity_value)
	fps_sensitivity_slider = HSlider.new()
	fps_sensitivity_slider.name = "AimSensitivitySlider"
	fps_sensitivity_slider.position = Vector2(14, 72)
	fps_sensitivity_slider.size = Vector2(300, 18)
	fps_sensitivity_slider.min_value = NightfallPlayer.MIN_AIM_SENSITIVITY
	fps_sensitivity_slider.max_value = NightfallPlayer.MAX_AIM_SENSITIVITY
	fps_sensitivity_slider.step = 0.05
	fps_sensitivity_slider.value_changed.connect(_on_aim_sensitivity_changed)
	fps_options_panel.add_child(fps_sensitivity_slider)
	fps_invert_toggle = Button.new()
	fps_invert_toggle.name = "InvertYToggle"
	fps_invert_toggle.toggle_mode = true
	fps_invert_toggle.position = Vector2(14, 108)
	fps_invert_toggle.size = Vector2(300, 35)
	fps_invert_toggle.add_theme_font_size_override("font_size", 11)
	fps_invert_toggle.toggled.connect(_on_aim_invert_toggled)
	fps_options_panel.add_child(fps_invert_toggle)
	var footer := _hud_label("LOCAL DEVICE PROFILE // APPLIES TO TOUCH + STICK", Vector2(14, 151), 9, Color("C8BBA1"))
	fps_options_panel.add_child(footer)
	_sync_fps_options()

func _toggle_fps_options() -> void:
	if not fps_options_panel:
		return
	fps_options_panel.visible = not fps_options_panel.visible
	fps_options_toggle.text = "CLOSE FPS OPTIONS" if fps_options_panel.visible else "FPS OPTIONS"
	if player and is_instance_valid(player.touch_overlay):
		player.touch_overlay.set_look_input_enabled(not fps_options_panel.visible)

func _on_aim_sensitivity_changed(value: float) -> void:
	if player:
		player.set_aim_sensitivity(value)

func _on_aim_invert_toggled(enabled: bool) -> void:
	if player:
		player.set_aim_invert_y(enabled)

func _sync_fps_options(_sensitivity: float = -1.0, _invert_y: bool = false) -> void:
	if not player or not fps_sensitivity_slider or not fps_invert_toggle or not fps_sensitivity_value:
		return
	fps_sensitivity_slider.set_value_no_signal(player.aim_sensitivity)
	fps_sensitivity_value.text = "%.2fx" % player.aim_sensitivity
	fps_invert_toggle.set_pressed_no_signal(player.aim_invert_y)
	fps_invert_toggle.text = "INVERT Y // ON" if player.aim_invert_y else "INVERT Y // OFF"

func _hud_frame(position_value: Vector2, size_value: Vector2) -> ColorRect:
	var frame := ColorRect.new()
	frame.position = position_value
	frame.size = size_value
	frame.color = Color("100C0AE6")
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return frame

func _hud_label(text_value: String, position_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("080604"))
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _update_combat_hud() -> void:
	if not player_vitality_label or not player:
		return
	player_vitality_label.text = "%s // VITALITY %s / %s" % [player.class_callsign(), player.vitality, player.max_vitality]
	player_vitality_bar.max_value = player.max_vitality
	player_vitality_bar.value = player.vitality
	veil_label.text = "%s // READY" % player.class_ability_name() if veil_cooldown_remaining <= 0.0 else "%s // %.1fs" % [player.class_ability_name(), veil_cooldown_remaining]
	kill_label.text = "WHARF // %s / %s" % [kills, enemies.size()]
	if boss_active and conductor and not conductor.is_defeated:
		objective_label.text = "LEVEL %02d // %s // BREAK THE CORE" % [story_mission_id, campaign_title]
	else:
		objective_label.text = "LEVEL %02d // %s // CHECKPOINT %s / %s" % [story_mission_id, campaign_title, active_checkpoint_index, campaign_checkpoint_count]
	boss_status_label.text = status_message

func _update_boss_hud(vitality: int, maximum: int, phase: int) -> void:
	if not boss_frame:
		return
	boss_frame.visible = true
	boss_bar.max_value = maximum
	boss_bar.value = vitality
	boss_label.text = "%s // PHASE %s // %s / %s" % [str(active_boss_profile.get("title", "DROWNED ADMIRAL")), phase, vitality, maximum]

func _update_follow_camera(delta: float) -> void:
	if not is_instance_valid(camera) or not is_instance_valid(player) or player.is_first_person():
		return
	var desired_position := player.global_position + Vector3(0, 8.8, 12.5)
	camera.global_position = camera.global_position.lerp(desired_position, minf(1.0, delta * 2.2))
	camera.look_at(player.global_position + Vector3(0, 1.0, -3.4), Vector3.UP)

func _return_to_campaign_hub() -> void:
	get_tree().change_scene_to_file("res://scenes/campaign_hub.tscn")

func _export_completion_record() -> void:
	if not victory:
		_set_status("EXPORT UNAVAILABLE // DEFEAT THE MISSION FIRST", 2.0)
		return
	var result := CampaignCompletionRecord.record_victory(story_mission_id, campaign_title, StoryProgress.defeated_through())
	if result.get("written", false):
		_set_status("COMPLETION RECORD READY // EXPORT OR SHARE THE LOCAL JSON FILE", 4.0)
		return
	_set_status("COMPLETION RECORD EXPORT FAILED // LOCAL VICTORY REMAINS SAVED", 3.0)
