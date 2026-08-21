class_name ObservatoryArena
extends Node3D

const NightfallPlayer = preload("res://scripts/gameplay/nightfall_player.gd")
const NightfallProjectile = preload("res://scripts/gameplay/nightfall_projectile.gd")
const TouchOverlay = preload("res://scripts/gameplay/nightfall_touch_overlay.gd")
const NightfallAudio = preload("res://scripts/presentation/nightfall_audio.gd")
const HollowedActor = preload("res://scripts/presentation/hollowed_actor.gd")
const ObservatoryConductor = preload("res://scripts/gameplay/observatory_conductor.gd")

@export_enum("last_platform", "static_trail") var entry_branch := "last_platform"
var audio_layer: NightfallAudio
var cue_caption: Label
var boss_health_bar: ProgressBar
var boss_health_label: Label
var boss_status_label: Label

func _ready() -> void:
	name = "ObservatoryArena"
	audio_layer = NightfallAudio.new()
	add_child(audio_layer)
	_build_audio_caption_layer()
	audio_layer.play_cue("cinematic_transition")
	_build_environment()
	_build_shell()
	_build_relay_core()
	_build_admiralty_dressing()
	_build_branch_entry(entry_branch)
	_spawn_defenders()
	_spawn_conductor()
	_spawn_player_controls()

func configure_branch(branch: String) -> void:
	entry_branch = branch if branch == "last_platform" or branch == "static_trail" else "last_platform"

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "ObservatoryAtmosphere"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("080604")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("5E482E")
	environment.ambient_light_energy = 0.5
	environment.glow_enabled = true
	environment.glow_intensity = 1.25
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.light_color = Color("B68A39")
	key.light_energy = 1.6
	key.rotation_degrees = Vector3(-48, 24, 0)
	add_child(key)
	var core_light := OmniLight3D.new()
	core_light.light_color = Color("8D2634")
	core_light.light_energy = 5.0
	core_light.omni_range = 16.0
	core_light.position = Vector3(0, 4, -3)
	add_child(core_light)
	var camera := Camera3D.new()
	camera.name = "ObservatoryCamera"
	camera.position = Vector3(0, 10.5, 17.5)
	camera.rotation_degrees = Vector3(-24, 180, 0)
	add_child(camera)

func _build_audio_caption_layer() -> void:
	var layer := CanvasLayer.new()
	layer.name = "ObservatoryAudioAccessibilityCaptions"
	cue_caption = Label.new()
	cue_caption.position = Vector2(24, 96)
	cue_caption.add_theme_font_size_override("font_size", 15)
	cue_caption.add_theme_color_override("font_color", Color("F5F0E9"))
	cue_caption.add_theme_color_override("font_outline_color", Color("08070C"))
	cue_caption.add_theme_constant_override("outline_size", 5)
	layer.add_child(cue_caption)
	add_child(layer)
	audio_layer.subtitle_requested.connect(func(subtitle: String) -> void: cue_caption.text = subtitle)

func _build_shell() -> void:
	_block("ObservatoryFloor", Vector3(24, 0.4, 28), Vector3(0, -0.2, -2), Color("110C09"), 0.0, true)
	for x in [-11.0, 11.0]:
		_block("ObservatoryWall_%s" % x, Vector3(0.65, 7, 26), Vector3(x, 3.5, -2), Color("2A1A11"), 0.0, true)
	for z in [-13.5, 9.5]:
		_block("ObservatoryRib_%s" % z, Vector3(21, 0.42, 0.42), Vector3(0, 6.25, z), Color("4E311A"), 0.0)
	for x in [-6.5, 6.5]:
		for z in [-9.0, -3.0, 3.0]:
			_block("AstralPillar_%s_%s" % [x, z], Vector3(0.85, 5.7, 0.85), Vector3(x, 2.85, z), Color("342114"), 0.0, true)
			_block("PillarTrace_%s_%s" % [x, z], Vector3(0.12, 3.6, 0.12), Vector3(x + sign(x) * 0.48, 2.6, z), Color("B68A39"), 1.5)

func _build_relay_core() -> void:
	var core := MeshInstance3D.new()
	core.name = "ObservatoryRelayCore"
	var mesh := SphereMesh.new()
	mesh.radius = 1.8
	mesh.height = 3.6
	mesh.material = _material(Color("5B341C"), 0.58, 0.42)
	core.mesh = mesh
	core.position = Vector3(0, 2.8, -4.8)
	add_child(core)
	var aperture := MeshInstance3D.new()
	aperture.name = "EclipseAperture"
	var ring := TorusMesh.new()
	ring.inner_radius = 2.1
	ring.outer_radius = 2.28
	ring.material = _material(Color("8D2634"), 0.42, 2.8)
	aperture.mesh = ring
	aperture.position = Vector3(0, 3.0, -4.8)
	aperture.rotation_degrees.x = 90.0
	add_child(aperture)
	for index in range(6):
		var angle := TAU * float(index) / 6.0
		_block("CoreObelisk_%s" % index, Vector3(0.52, 3.2, 0.52), Vector3(cos(angle) * 4.1, 1.6, -4.8 + sin(angle) * 4.1), Color("6B4724"), 0.35, true)

func _build_admiralty_dressing() -> void:
	for x in [-9.4, 9.4]:
		_block("AdmiraltyMast_%s" % x, Vector3(0.34, 7.4, 0.34), Vector3(x, 3.7, -5.4), Color("3A2413"), 0.0)
		_block("AdmiraltySail_%s" % x, Vector3(0.12, 3.0, 3.9), Vector3(x, 4.3, -5.4), Color("100B09"), 0.0)
		_block("AdmiraltyBrass_%s" % x, Vector3(0.16, 0.16, 0.16), Vector3(x - sign(x) * 0.2, 4.3, -5.4), Color("B68A39"), 1.0)
	for z in [-10.8, 3.6]:
		_block("RiggingBeam_%s" % z, Vector3(19.0, 0.2, 0.4), Vector3(0, 5.35, z), Color("50341C"), 0.0)

func _build_branch_entry(branch: String) -> void:
	if branch == "static_trail":
		_build_lattice_gap_entry()
	else:
		_build_civic_service_entry()

func _build_civic_service_entry() -> void:
	var entry := Node3D.new()
	entry.name = "CivicServiceEntry"
	add_child(entry)
	for x in [-3.2, 3.2]:
		_block_to(entry, "ServiceDoor_%s" % x, Vector3(2.0, 4.2, 0.5), Vector3(x, 2.1, 8.7), Color("1C312B"), 0.0, true)
		_block_to(entry, "ServiceGuide_%s" % x, Vector3(0.16, 3.1, 0.16), Vector3(x, 2.4, 8.38), Color("4A877A"), 1.9)
	_block_to(entry, "ServiceCanopy", Vector3(7.4, 0.45, 1.2), Vector3(0, 4.4, 8.7), Color("4C321B"), 0.0, true)
	for z in [6.2, 4.1, 2.0]:
		_block_to(entry, "CivicRoute_%s" % z, Vector3(1.8, 0.08, 0.55), Vector3(0, 0.06, z), Color("4A877A"), 1.2)

func _build_lattice_gap_entry() -> void:
	var entry := Node3D.new()
	entry.name = "LatticeGapEntry"
	add_child(entry)
	for x in [-4.2, -2.8, 2.8, 4.2]:
		_block_to(entry, "LatticeFrame_%s" % x, Vector3(0.25, 5.4, 0.25), Vector3(x, 2.7, 8.5), Color("592522"), 0.9, true)
	for y in [1.2, 2.4, 3.6]:
		_block_to(entry, "LatticeBeam_%s" % y, Vector3(8.4, 0.1, 0.12), Vector3(0, y, 8.5), Color("8D2634"), 2.3)
	_block_to(entry, "CipherWindow", Vector3(1.7, 4.5, 0.3), Vector3(0, 2.25, 8.5), Color("08070C"), 0.0)
	for z in [6.1, 3.8, 1.5]:
		_block_to(entry, "CipherTrace_%s" % z, Vector3(0.7, 0.08, 0.5), Vector3(0, 0.06, z), Color("8D2634"), 1.6)

func _spawn_defenders() -> void:
	for index in 3:
		var defender := HollowedActor.new()
		defender.name = "ObservatoryHollowed_%s" % index
		defender.accent = Color("8D2634") if index == 0 else Color("B68A39")
		defender.position = Vector3(-3.5 + index * 3.5, 0.1, -2.5 - index * 1.5)
		defender.state_changed.connect(func(state_name: String) -> void: if state_name == "attack" or state_name == "hit" or state_name == "dissolve": audio_layer.play_cue("enemy_" + state_name))
		add_child(defender)

func _spawn_conductor() -> void:
	var conductor := ObservatoryConductor.new()
	conductor.configure_branch(entry_branch)
	conductor.phase_changed.connect(func(_phase: int, mechanic: String) -> void: audio_layer.play_cue("cinematic_transition"); cue_caption.text = mechanic)
	conductor.defeated.connect(func(reward: Dictionary) -> void: cue_caption.text = "REWARD // " + reward["title"])
	conductor.vitality_changed.connect(_update_boss_hud)
	conductor.attack_windup_started.connect(func(attack_name: String, _duration: float, _phase: int) -> void: boss_status_label.text = "WINDUP // " + attack_name + " // DODGE"; cue_caption.text = "INCOMING // " + attack_name)
	conductor.attack_resolved.connect(func(_results: Array[Dictionary]) -> void: boss_status_label.text = "ATTACK RESOLVED // REPOSITION")
	_build_boss_hud(conductor.max_vitality)
	add_child(conductor)

func _build_boss_hud(maximum: int) -> void:
	var layer := CanvasLayer.new()
	layer.name = "ConductorBossHUD"
	var frame := ColorRect.new()
	frame.position = Vector2(24, 22)
	frame.size = Vector2(350, 54)
	frame.color = Color("120D1ECC")
	layer.add_child(frame)
	boss_health_label = Label.new()
	boss_health_label.name = "ConductorVitalityLabel"
	boss_health_label.position = Vector2(36, 28)
	boss_health_label.add_theme_font_size_override("font_size", 13)
	boss_health_label.add_theme_color_override("font_color", Color("F5F0E9"))
	boss_health_label.text = "CONDUCTOR // PHASE 1 // " + str(maximum) + " / " + str(maximum)
	layer.add_child(boss_health_label)
	boss_health_bar = ProgressBar.new()
	boss_health_bar.name = "ConductorVitalityBar"
	boss_health_bar.position = Vector2(36, 48)
	boss_health_bar.size = Vector2(326, 12)
	boss_health_bar.min_value = 0
	boss_health_bar.max_value = maximum
	boss_health_bar.value = maximum
	boss_health_bar.show_percentage = false
	layer.add_child(boss_health_bar)
	boss_status_label = Label.new()
	boss_status_label.name = "ConductorAttackStatus"
	boss_status_label.position = Vector2(36, 62)
	boss_status_label.add_theme_font_size_override("font_size", 9)
	boss_status_label.add_theme_color_override("font_color", Color("E7CB63"))
	boss_status_label.text = "READING CORE SIGNAL"
	layer.add_child(boss_status_label)
	add_child(layer)

func _update_boss_hud(vitality: int, maximum: int, phase: int) -> void:
	if boss_health_bar:
		boss_health_bar.max_value = maximum
		boss_health_bar.value = vitality
	if boss_health_label:
		boss_health_label.text = "DROWNED ADMIRAL // PHASE " + str(phase) + " // " + str(vitality) + " / " + str(maximum)
	if boss_status_label and vitality <= 0:
		boss_status_label.text = "CORE SILENCED // REWARD RECOVERED"

func _spawn_player_controls() -> void:
	var player := NightfallPlayer.new()
	player.position = Vector3(0, 0, 6.8)
	player.fire_requested.connect(_fire_projectile)
	add_child(player)
	var layer := CanvasLayer.new()
	layer.name = "ObservatoryTouchControls"
	var overlay := TouchOverlay.new()
	layer.add_child(overlay)
	add_child(layer)
	player.set_touch_overlay(overlay)

func _fire_projectile(origin: Vector3, direction: Vector3) -> void:
	audio_layer.play_cue("projectile_fire")
	var projectile := NightfallProjectile.new()
	add_child(projectile)
	projectile.fire(origin, direction)
	var result: Dictionary = projectile.resolve_segment(18.0)
	if result["kind"] == "target":
		audio_layer.play_cue("impact_target")
	elif result["kind"] == "solid":
		audio_layer.play_cue("impact_solid")

func _block(block_name: String, size: Vector3, position_value: Vector3, color: Color, emission: float, solid: bool = false) -> void:
	_block_to(self, block_name, size, position_value, color, emission, solid)

func _block_to(parent: Node3D, block_name: String, size: Vector3, position_value: Vector3, color: Color, emission: float, solid: bool = false) -> void:
	var block := MeshInstance3D.new()
	block.name = block_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _material(color, 0.4, emission)
	block.mesh = mesh
	block.position = position_value
	parent.add_child(block)
	if solid:
		var obstacle := StaticBody3D.new()
		obstacle.name = block_name + "Collision"
		obstacle.collision_layer = 1
		obstacle.position = position_value
		var collider := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collider.shape = shape
		obstacle.add_child(collider)
		parent.add_child(obstacle)

func _material(color: Color, metallic: float, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.36
	material.emission_enabled = emission > 0.0
	material.emission = color
	material.emission_energy_multiplier = emission
	return material
