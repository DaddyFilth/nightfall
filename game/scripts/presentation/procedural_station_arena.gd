extends Node3D

const HollowedActor = preload("res://scripts/presentation/hollowed_actor.gd")
const NightfallPlayer = preload("res://scripts/gameplay/nightfall_player.gd")
const NightfallProjectile = preload("res://scripts/gameplay/nightfall_projectile.gd")
const TouchOverlay = preload("res://scripts/gameplay/nightfall_touch_overlay.gd")
const NightfallAudio = preload("res://scripts/presentation/nightfall_audio.gd")
const GamepadRemapCapture = preload("res://scripts/gameplay/gamepad_remap_capture.gd")
const GamepadRebindPrompt = preload("res://scripts/gameplay/gamepad_rebind_prompt.gd")
const DOCKYARD_BACKDROP_PATH := "res://assets/textures/brasswake-dockyards-bundled.png"
const FLOOR_COLOR := Color("100C09")
const PANEL_COLOR := Color("281A12")
const BRASS := Color("B68A39")
const SEAFOG := Color("4A877A")
const CRIMSON := Color("8D2634")
const WET_STONE := Color("171A1C")
const RUSTED_IRON := Color("352A20")
const MIDNIGHT_STEEL := Color("121B22")
var audio_layer: NightfallAudio
var cue_caption: Label
var ambient_time := 0.0
var animated_sails: Array[MeshInstance3D] = []
var fog_banks: Array[MeshInstance3D] = []
var fog_origins: Array[Vector3] = []
var premium_lanterns: Array[OmniLight3D] = []
var eclipse_core: MeshInstance3D
var eclipse_core_light: OmniLight3D
var backdrop_art: MeshInstance3D
var backdrop_art_origin := Vector3.ZERO
var wet_deck_reflections: Array[MeshInstance3D] = []
var wet_deck_reflection_origins: Array[Vector3] = []

func _ready() -> void:
	audio_layer = NightfallAudio.new()
	add_child(audio_layer)
	_build_audio_caption_layer()
	audio_layer.play_cue("cinematic_transition")
	_build_environment()
	_build_bundled_art_backdrop()
	_build_floor()
	_build_rail_concourse()
	_build_tactical_cover()
	_build_galleon_dressing()
	_build_atmosphere_fx()
	_build_premium_depth_fx()
	_build_eclipse_engine()
	_spawn_hollowed()
	_spawn_player_controls()
	_spawn_gamepad_rebind_prompt()
	set_process(true)

func _process(delta: float) -> void:
	ambient_time += delta
	for index in animated_sails.size():
		var sail := animated_sails[index]
		if not is_instance_valid(sail):
			continue
		sail.rotation_degrees.z = sin(ambient_time * 0.86 + float(index) * 1.7) * 4.2
		sail.scale.z = 1.0 + sin(ambient_time * 1.4 + float(index)) * 0.05
	for index in fog_banks.size():
		if index >= fog_origins.size():
			continue
		var fog := fog_banks[index]
		if not is_instance_valid(fog):
			continue
		var origin := fog_origins[index]
		fog.position.x = origin.x + sin(ambient_time * 0.28 + float(index) * 0.9) * 2.1
		fog.position.z = origin.z + cos(ambient_time * 0.19 + float(index)) * 0.85
		fog.scale = Vector3.ONE * (1.0 + sin(ambient_time * 0.58 + float(index)) * 0.06)
	for index in premium_lanterns.size():
		var lantern := premium_lanterns[index]
		if is_instance_valid(lantern):
			lantern.light_energy = 1.18 + sin(ambient_time * 2.4 + float(index) * 0.81) * 0.18
	if is_instance_valid(eclipse_core):
		var pulse := 1.0 + sin(ambient_time * 2.1) * 0.07
		eclipse_core.scale = Vector3.ONE * pulse
	if is_instance_valid(eclipse_core_light):
		eclipse_core_light.light_energy = 4.6 + sin(ambient_time * 2.1) * 1.05
	if is_instance_valid(backdrop_art):
		backdrop_art.position.y = backdrop_art_origin.y + sin(ambient_time * 0.42) * 0.045
		var backdrop_pulse := 1.0 + sin(ambient_time * 0.84) * 0.008
		backdrop_art.scale = Vector3(backdrop_pulse, backdrop_pulse, 1.0)
	for index in wet_deck_reflections.size():
		if index >= wet_deck_reflection_origins.size():
			continue
		var reflection := wet_deck_reflections[index]
		if not is_instance_valid(reflection):
			continue
		var reflection_pulse := 1.0 + sin(ambient_time * 1.25 + float(index) * 0.8) * 0.07
		reflection.scale = Vector3(reflection_pulse, 1.0, reflection_pulse)

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "BrasswakeAtmosphere"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("050708")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("5D635C")
	environment.ambient_light_energy = 0.34
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.12
	environment.tonemap_white = 2.4
	environment.glow_enabled = true
	environment.glow_intensity = 0.78
	environment.fog_enabled = true
	environment.fog_light_color = Color("43575A")
	environment.fog_light_energy = 0.48
	environment.fog_density = 0.008
	environment.fog_sky_affect = 0.58
	environment.fog_depth_begin = 8.0
	environment.fog_depth_end = 46.0
	world.environment = environment
	add_child(world)
	var moon := DirectionalLight3D.new()
	moon.name = "EclipsedSeaMoon"
	moon.light_color = Color("93B1AE")
	moon.light_energy = 1.7
	moon.light_indirect_energy = 0.55
	moon.shadow_enabled = true
	moon.shadow_opacity = 0.62
	moon.rotation_degrees = Vector3(-48, -32, 0)
	add_child(moon)
	var brass_key := SpotLight3D.new()
	brass_key.name = "BrasswakeKeyLight"
	brass_key.position = Vector3(-4.8, 6.5, 7.6)
	brass_key.rotation_degrees = Vector3(-52, -18, 0)
	brass_key.light_color = Color("D6A251")
	brass_key.light_energy = 5.8
	brass_key.spot_range = 22.0
	brass_key.spot_angle = 42.0
	brass_key.shadow_enabled = true
	add_child(brass_key)
	var sea_rim := SpotLight3D.new()
	sea_rim.name = "BrasswakeRimLight"
	sea_rim.position = Vector3(5.8, 5.1, -7.2)
	sea_rim.rotation_degrees = Vector3(-34, 146, 0)
	sea_rim.light_color = Color("3C9B97")
	sea_rim.light_energy = 4.1
	sea_rim.spot_range = 18.0
	sea_rim.spot_angle = 36.0
	sea_rim.shadow_enabled = true
	add_child(sea_rim)
	var fill := OmniLight3D.new()
	fill.name = "HarborSeaFogFill"
	fill.light_color = SEAFOG
	fill.light_energy = 3.1
	fill.omni_range = 15.0
	fill.position = Vector3(0, 3, 0)
	add_child(fill)
	var camera := Camera3D.new()
	camera.name = "PresentationCamera"
	camera.fov = 58.0
	camera.near = 0.05
	camera.position = Vector3(0, 8.0, 14.2)
	camera.rotation_degrees = Vector3(-22, 180, 0)
	add_child(camera)

func _build_bundled_art_backdrop() -> void:
	var backdrop_frame := Node3D.new()
	backdrop_frame.name = "BundledDockyardBackdrop"
	backdrop_frame.position = Vector3(0, 4.75, -15.15)
	add_child(backdrop_frame)
	var backdrop := MeshInstance3D.new()
	backdrop.name = "BundledDockyardArtwork"
	var backdrop_mesh := QuadMesh.new()
	backdrop_mesh.size = Vector2(15.6, 8.78)
	backdrop.mesh = backdrop_mesh
	var backdrop_material := StandardMaterial3D.new()
	var bundled_texture := _load_bundled_backdrop_texture()
	backdrop_material.albedo_texture = bundled_texture
	backdrop_material.albedo_color = Color("81979B") if bundled_texture == null else Color.WHITE
	backdrop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	backdrop_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	backdrop_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	backdrop_material.emission_enabled = true
	backdrop_material.emission = Color("1D3232")
	backdrop_material.emission_energy_multiplier = 0.08
	backdrop.material_override = backdrop_material
	backdrop_frame.add_child(backdrop)
	backdrop_art = backdrop
	backdrop_art_origin = backdrop.position
	_block("BackdropFrameTop", Vector3(16.2, 0.22, 0.22), Vector3(0, 9.2, -15.3), BRASS, 0.6)
	_block("BackdropFrameLeft", Vector3(0.22, 8.9, 0.22), Vector3(-8.0, 4.75, -15.3), BRASS, 0.6)
	_block("BackdropFrameRight", Vector3(0.22, 8.9, 0.22), Vector3(8.0, 4.75, -15.3), BRASS, 0.6)

func _load_bundled_backdrop_texture() -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(DOCKYARD_BACKDROP_PATH))
	if image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

func _build_audio_caption_layer() -> void:
	var layer := CanvasLayer.new()
	layer.name = "AudioAccessibilityCaptions"
	cue_caption = Label.new()
	cue_caption.position = Vector2(24, 96)
	cue_caption.add_theme_font_size_override("font_size", 15)
	cue_caption.add_theme_color_override("font_color", Color("F5F0E9"))
	cue_caption.add_theme_color_override("font_outline_color", Color("08070C"))
	cue_caption.add_theme_constant_override("outline_size", 5)
	layer.add_child(cue_caption)
	add_child(layer)
	audio_layer.subtitle_requested.connect(func(subtitle: String) -> void: cue_caption.text = subtitle)

func _build_floor() -> void:
	_block("ArenaFloor", Vector3(20, 0.35, 32), Vector3(0, -0.2, 0), FLOOR_COLOR, 0.0, true)
	for z in range(-14, 16, 2):
		_block("DeckPlank_%s" % z, Vector3(15.4, 0.055, 1.72), Vector3(0, 0.01, z), Color("211B15") if z % 4 == 0 else Color("181512"), 0.0)
		_block("DeckSeam_%s" % z, Vector3(15.55, 0.024, 0.065), Vector3(0, 0.055, z + 0.86), Color("090A0B"), 0.0)
	for x in [-5.8, -1.9, 1.9, 5.8]:
		for z in [-11.0, -5.0, 1.0, 7.0, 13.0]:
			_block("DeckBolt_%s_%s" % [x, z], Vector3(0.13, 0.08, 0.13), Vector3(x, 0.07, z), BRASS.darkened(0.45), 0.14)
	for puddle_position in [Vector3(-3.5, 0.05, -1.7), Vector3(2.6, 0.05, 3.1), Vector3(0.4, 0.05, -7.5)]:
		var puddle := MeshInstance3D.new()
		puddle.name = "RainPuddle_%s" % puddle_position.z
		var puddle_mesh := CylinderMesh.new()
		puddle_mesh.top_radius = 1.25
		puddle_mesh.bottom_radius = 1.35
		puddle_mesh.height = 0.018
		puddle.mesh = puddle_mesh
		puddle.position = puddle_position
		puddle.material_override = _material(Color("15282A"), 0.86, 0.08, 0.18)
		add_child(puddle)
		wet_deck_reflections.append(puddle)
		wet_deck_reflection_origins.append(puddle.position)
	for z in range(-14, 15, 4):
		_block("TrackLeft_%s" % z, Vector3(0.24, 0.12, 2.9), Vector3(-2.4, 0.03, z), CRIMSON, 1.3)
		_block("TrackRight_%s" % z, Vector3(0.24, 0.12, 2.9), Vector3(2.4, 0.03, z), BRASS, 1.0)
		_block("TrackInset_%s" % z, Vector3(3.9, 0.035, 0.08), Vector3(0, 0.055, z), MIDNIGHT_STEEL, 0.12)
	for x in [-8.5, 8.5]:
		_block("PlatformWall_%s" % x, Vector3(0.55, 5.4, 30), Vector3(x, 2.7, 0), PANEL_COLOR, 0.0, true)
		for z in range(-12, 13, 6):
			_block("WharfPost_%s_%s" % [x, z], Vector3(0.82, 6.2, 0.82), Vector3(x * 0.78, 3.1, z), Color("2D1A0F"), 0.0, true)

func _build_rail_concourse() -> void:
	for z in range(-12, 13, 6):
		_block("Crossbeam_%s" % z, Vector3(17, 0.42, 0.42), Vector3(0, 5.2, z), Color("342344"), 0.0)
		for x in [-5.5, 5.5]:
			_block("Pillar_%s_%s" % [x, z], Vector3(0.72, 5.0, 0.72), Vector3(x, 2.5, z), Color("2c1d3a"), 0.0, true)
			_block("PillarLight_%s_%s" % [x, z], Vector3(0.12, 2.9, 0.12), Vector3(x + sign(x) * 0.42, 2.7, z), BRASS if x < 0 else SEAFOG, 1.7)
			var lantern := OmniLight3D.new()
			lantern.name = "HarborLantern_%s_%s" % [x, z]
			lantern.position = Vector3(x + sign(x) * 0.35, 3.05, z)
			lantern.light_color = BRASS if x < 0 else SEAFOG
			lantern.light_energy = 1.35
			lantern.omni_range = 5.0
			add_child(lantern)
			premium_lanterns.append(lantern)
	for side in [-1, 1]:
		for z in [-9, 3, 9]:
			_block("Cover_%s_%s" % [side, z], Vector3(2.3, 1.25, 0.75), Vector3(side * 5.4, 0.62, z), Color("17121f"), 0.0, true)

func _build_tactical_cover() -> void:
	var cover_positions: Array[Vector3] = [Vector3(-2.9, 0.62, -1.8), Vector3(3.0, 0.62, -4.3), Vector3(-4.2, 0.62, -8.8), Vector3(4.4, 0.62, 4.8)]
	for index in cover_positions.size():
		var cover_position: Vector3 = cover_positions[index]
		_block("CargoCrate_%s" % index, Vector3(1.55, 1.22, 1.38), cover_position, RUSTED_IRON, 0.0, true)
		_block("CargoFacePlate_%s" % index, Vector3(1.60, 0.78, 0.065), cover_position + Vector3(0, 0.02, -0.725), MIDNIGHT_STEEL, 0.05)
		_block("CargoStrap_%s" % index, Vector3(1.63, 0.12, 0.16), cover_position + Vector3(0, 0.18, 0.0), BRASS.darkened(0.32), 0.22)
		_block("CargoStencil_%s" % index, Vector3(0.02, 0.42, 0.78), cover_position + Vector3(0.79, 0.05, 0), SEAFOG.darkened(0.38), 0.08)
	for x in [-7.25, 7.25]:
		for z in [-8.0, 0.0, 8.0]:
			_block("MooringBollard_%s_%s" % [x, z], Vector3(0.45, 0.78, 0.45), Vector3(x, 0.39, z), Color("141312"), 0.12)

func _build_galleon_dressing() -> void:
	for x in [-6.9, 6.9]:
		_block("GalleonMast_%s" % x, Vector3(0.34, 7.0, 0.34), Vector3(x, 3.5, -5.8), Color("3A2413"), 0.0)
		var sail := _block("BlackSail_%s" % x, Vector3(0.14, 2.8, 3.6), Vector3(x, 4.2, -5.8), Color("100C0A"), 0.0)
		animated_sails.append(sail)
		_block("SailRivet_%s" % x, Vector3(0.17, 0.17, 0.17), Vector3(x - sign(x) * 0.18, 4.2, -5.8), BRASS, 1.1)
		_block("RiggingBeam_%s" % x, Vector3(0.12, 0.12, 5.5), Vector3(x, 5.55, -5.8), Color("211710"), 0.0)
	for z in [-10.5, -4.5, 1.5]:
		_block("ShipRib_%s" % z, Vector3(14.8, 0.24, 0.6), Vector3(0, 2.2, z), Color("4A2A16"), 0.0)
		_block("TidePipe_%s" % z, Vector3(0.28, 0.28, 9.8), Vector3(-7.45, 1.9, z), BRASS, 0.45)

func _build_atmosphere_fx() -> void:
	var layer := Node3D.new()
	layer.name = "BrasswakeAtmosphereFX"
	add_child(layer)
	for index in range(3):
		var fog := MeshInstance3D.new()
		fog.name = "SeaFogBank_%s" % index
		var fog_mesh := SphereMesh.new()
		fog_mesh.radius = 2.2 + float(index) * 0.35
		fog_mesh.height = 1.2
		fog_mesh.radial_segments = 16
		fog_mesh.rings = 4
		fog.mesh = fog_mesh
		fog.material_override = _mist_material(0.12 - float(index) * 0.018)
		fog.position = Vector3(-5.4 + float(index) * 5.3, 1.4 + float(index) * 0.16, -1.2 - float(index) * 3.2)
		fog.scale = Vector3(1.7, 0.28, 1.08)
		layer.add_child(fog)
		fog_banks.append(fog)
		fog_origins.append(fog.position)
	for index in range(2):
		var spray := GPUParticles3D.new()
		spray.name = "SeaSpray_%s" % index
		spray.amount = 46
		spray.lifetime = 1.45
		spray.position = Vector3(-5.7 + float(index) * 11.4, 0.45, -3.4)
		var spray_mesh := SphereMesh.new()
		spray_mesh.radius = 0.035
		spray_mesh.height = 0.07
		spray_mesh.material = _mist_material(0.68)
		spray.draw_pass_1 = spray_mesh
		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.16 if index == 0 else -0.16, 1.0, 0.2)
		process.spread = 28.0
		process.initial_velocity_min = 1.2
		process.initial_velocity_max = 2.0
		process.gravity = Vector3(0, -3.8, 0)
		spray.process_material = process
		layer.add_child(spray)

func _build_premium_depth_fx() -> void:
	var layer := Node3D.new()
	layer.name = "PremiumDepthFX"
	add_child(layer)
	for index in range(2):
		var sparks := GPUParticles3D.new()
		sparks.name = "AtmosphericSparks_%s" % index
		sparks.amount = 20
		sparks.lifetime = 2.6
		sparks.position = Vector3(-3.9 + float(index) * 7.8, 1.5, -5.5 - float(index) * 3.2)
		var spark_mesh := SphereMesh.new()
		spark_mesh.radius = 0.025
		spark_mesh.height = 0.05
		spark_mesh.material = _material(BRASS.lightened(0.18), 0.55, 2.6, 0.18)
		sparks.draw_pass_1 = spark_mesh
		var process := ParticleProcessMaterial.new()
		process.direction = Vector3(0.08 if index == 0 else -0.08, 1.0, 0.02)
		process.spread = 18.0
		process.initial_velocity_min = 0.18
		process.initial_velocity_max = 0.48
		process.gravity = Vector3(0.0, 0.22, 0.0)
		sparks.process_material = process
		layer.add_child(sparks)

func _mist_material(alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.29, 0.53, 0.48, alpha)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	return material

func _build_eclipse_engine() -> void:
	var engine := MeshInstance3D.new()
	engine.name = "EclipseEngine"
	var mesh := SphereMesh.new()
	mesh.radius = 1.55
	mesh.height = 3.1
	mesh.material = _material(Color("5B3B20"), 0.55, 0.22)
	engine.mesh = mesh
	engine.position = Vector3(0, 2.2, -11.2)
	add_child(engine)
	var core := MeshInstance3D.new()
	core.name = "EclipseCore"
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.53
	core_mesh.height = 1.06
	core_mesh.material = _material(CRIMSON, 0.34, 3.1)
	core.mesh = core_mesh
	core.position = Vector3(0, 2.2, -9.68)
	add_child(core)
	eclipse_core = core
	eclipse_core_light = OmniLight3D.new()
	eclipse_core_light.name = "EclipseCoreLight"
	eclipse_core_light.position = core.position
	eclipse_core_light.light_color = Color("E63F61")
	eclipse_core_light.light_energy = 4.6
	eclipse_core_light.omni_range = 9.0
	add_child(eclipse_core_light)
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var position := Vector3(cos(angle) * 3.0, 1.0, -11.2 + sin(angle) * 3.0)
		_block("EngineShard_%s" % index, Vector3(0.45, 2.4, 0.45), position, CRIMSON, 1.5)

func _spawn_hollowed() -> void:
	var positions := enemy_spawn_positions()
	for index in positions.size():
		var actor := HollowedActor.new()
		actor.name = "Hollowed_%s" % index
		actor.configure_archetype(enemy_archetype_for_index(index))
		if actor.archetype == "privateer":
			actor.accent = CRIMSON if index % 2 == 0 else SEAFOG
		actor.idle_offset = float(index) * 0.65
		actor.position = positions[index]
		actor.state_changed.connect(_play_enemy_state)
		add_child(actor)

func enemy_spawn_positions() -> Array[Vector3]:
	var positions: Array[Vector3] = [Vector3(-4.5, 0.1, -3.5), Vector3(4.5, 0.1, -5.2), Vector3(-2.8, 0.1, -8.0), Vector3(3.2, 0.1, -10.0)]
	return positions

func enemy_archetype_for_index(_index: int) -> String:
	return "privateer"

func _spawn_player_controls() -> void:
	var player := NightfallPlayer.new()
	player.position = Vector3(0, 0, 10.5)
	player.fire_requested.connect(_fire_projectile)
	player.ability_requested.connect(func() -> void: player.move_speed = 6.5)
	player.weapon_animation_started.connect(func(weapon_id: String) -> void: audio_layer.play_cue("wheel_lock_fire" if weapon_id == "wheel_lock" else "cutlass_swing"))
	add_child(player)
	var overlay_layer := CanvasLayer.new()
	overlay_layer.name = "TouchControls"
	var overlay := TouchOverlay.new()
	overlay_layer.add_child(overlay)
	add_child(overlay_layer)
	player.set_touch_overlay(overlay)

func _spawn_gamepad_rebind_prompt() -> void:
	var capture := GamepadRemapCapture.new()
	add_child(capture)
	var prompt := GamepadRebindPrompt.new()
	prompt.attach(capture)
	add_child(prompt)

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

func _play_enemy_state(state_name: String) -> void:
	if state_name == "attack" or state_name == "hit" or state_name == "dissolve":
		audio_layer.play_cue("enemy_" + state_name)

func _block(block_name: String, size: Vector3, local_position: Vector3, color: Color, emission: float, solid: bool = false) -> MeshInstance3D:
	var block := MeshInstance3D.new()
	block.name = block_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _material(color, 0.45, emission)
	block.mesh = mesh
	block.position = local_position
	add_child(block)
	if solid:
		var obstacle := StaticBody3D.new()
		obstacle.name = block_name + "Collision"
		obstacle.collision_layer = 1
		obstacle.collision_mask = 0
		obstacle.position = local_position
		var collider := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collider.shape = shape
		obstacle.add_child(collider)
		add_child(obstacle)
	return block

func _material(color: Color, metallic: float, emission: float, roughness: float = 0.38) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	material.rim_enabled = metallic >= 0.45
	material.rim = clampf(0.16 + metallic * 0.38, 0.0, 0.62)
	material.rim_tint = 0.38
	material.clearcoat_enabled = metallic >= 0.65
	material.clearcoat = 0.42 if metallic >= 0.65 else 0.0
	material.clearcoat_roughness = clampf(roughness * 0.72, 0.08, 0.5)
	material.emission_enabled = emission > 0.0
	material.emission = color
	material.emission_energy_multiplier = emission
	return material
