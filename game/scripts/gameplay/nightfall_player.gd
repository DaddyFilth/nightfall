class_name NightfallPlayer
extends CharacterBody3D

const NightfallInput = preload("res://scripts/gameplay/nightfall_input.gd")

const SOLID_LAYER := 1
const PLAYER_LAYER := 2
@export var move_speed := 5.2
@export var max_vitality := 100
@export var dodge_duration := 0.28
@export var knockback_force := 8.5
@export var knockback_decay := 22.0
var last_safe_position := Vector3.ZERO
var touch_overlay: NightfallTouchOverlay
var vitality := 100
var dodge_remaining := 0.0
var knockback_velocity := Vector3.ZERO
var cutlass_rig: Node3D
var wheel_lock_rig: Node3D
var fps_pitch_pivot: Node3D
var fps_camera: Camera3D
var fps_viewmodel: Node3D
var camera_pitch := 0.0
var cutlass_swing_remaining := 0.0
var wheel_lock_recoil_remaining := 0.0
var wheel_lock_reload_remaining := 0.0
var ads_requested := false
var ads_blend := 0.0
var touch_fire_held := false
const CUTLASS_SWING_DURATION := 0.42
const WHEEL_LOCK_RECOIL_DURATION := 0.24
const WHEEL_LOCK_RELOAD_DURATION := 0.58
const LOOK_SENSITIVITY := 0.0032
const GAMEPAD_LOOK_RATE := Vector2(520.0, 420.0)
const WHEEL_LOCK_REST_POSITION := Vector3(0.34, -0.28, -0.72)
const CUTLASS_REST_POSITION := Vector3(0.50, -0.34, -0.78)
const WHEEL_LOCK_ADS_OFFSET := Vector3(-0.23, 0.07, -0.16)
const CUTLASS_ADS_OFFSET := Vector3(-0.16, -0.07, -0.13)
const REST_FOV := 74.0
const ADS_FOV := 62.0
const ADS_BLEND_SPEED := 9.0
const AIM_SETTINGS_PATH := "user://nightfall/fps-settings.v1.cfg"
const MIN_AIM_SENSITIVITY := 0.5
const MAX_AIM_SENSITIVITY := 2.0
const DEFAULT_AIM_SENSITIVITY := 1.0
var aim_sensitivity := DEFAULT_AIM_SENSITIVITY
var aim_invert_y := false
signal fire_requested(origin: Vector3, direction: Vector3)
signal ability_requested
signal dodge_started
signal enemy_hit_resolved(amount: int, dodged: bool, vitality_remaining: int)
signal knockback_applied(impulse: Vector3)
signal weapon_animation_started(weapon_id: String)
signal weapon_animation_finished(weapon_id: String)
signal aim_preferences_changed(sensitivity: float, invert_y: bool)
signal ads_changed(is_aiming: bool)
signal reload_started
signal reload_finished

func _ready() -> void:
	name = "NightfallPlayer"
	collision_layer = PLAYER_LAYER
	collision_mask = SOLID_LAYER
	var body_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.65
	body_shape.shape = capsule
	body_shape.position.y = 0.82
	add_child(body_shape)
	_build_bloodwake_visual()
	_build_first_person_rig()
	last_safe_position = global_position
	vitality = max_vitality
	NightfallInput.ensure_default_actions()
	load_aim_preferences()

func _physics_process(delta: float) -> void:
	_update_weapon_animations(delta)
	if dodge_remaining > 0.0:
		dodge_remaining = max(0.0, dodge_remaining - delta)
	var move := NightfallInput.movement_vector()
	if touch_overlay and touch_overlay.virtual_move.length() > 0.01:
		move = touch_overlay.virtual_move
	var camera_relative_move := global_transform.basis * Vector3(move.x, 0, move.y)
	camera_relative_move.y = 0.0
	apply_move_intent(camera_relative_move, delta)
	var aim := NightfallInput.aim_vector()
	if aim.length() > 0.01:
		apply_look_delta(Vector2(aim.x * GAMEPAD_LOOK_RATE.x * delta, aim.y * GAMEPAD_LOOK_RATE.y * delta))
	if touch_overlay:
		apply_look_delta(touch_overlay.consume_look_delta())
	set_ads_requested(Input.is_action_pressed("nightfall_fire") or touch_fire_held)
	if Input.is_action_just_pressed("nightfall_fire"):
		fire_wheel_lock()
	if Input.is_action_just_pressed("nightfall_ability"):
		begin_cutlass_swing()
	if Input.is_action_just_pressed("nightfall_dodge"):
		begin_dodge()

func set_touch_overlay(overlay: NightfallTouchOverlay) -> void:
	touch_overlay = overlay
	overlay.fire_requested.connect(fire_wheel_lock)
	overlay.fire_hold_changed.connect(_set_touch_fire_held)
	overlay.ability_requested.connect(begin_cutlass_swing)
	overlay.dodge_requested.connect(begin_dodge)

func fire_wheel_lock() -> bool:
	if is_reloading():
		return false
	wheel_lock_recoil_remaining = WHEEL_LOCK_RECOIL_DURATION
	wheel_lock_reload_remaining = WHEEL_LOCK_RELOAD_DURATION
	weapon_animation_started.emit("wheel_lock")
	weapon_animation_started.emit("wheel_lock_reload")
	reload_started.emit()
	if is_instance_valid(fps_camera):
		fire_requested.emit(fps_camera.global_position, -fps_camera.global_transform.basis.z)
	else:
		fire_requested.emit(global_position + Vector3(0, 1.0, 0), -global_transform.basis.z)
	return true

func begin_cutlass_swing() -> void:
	cutlass_swing_remaining = CUTLASS_SWING_DURATION
	weapon_animation_started.emit("cutlass")
	ability_requested.emit()

func _update_weapon_animations(delta: float) -> void:
	_update_ads_presentation(delta)
	if wheel_lock_rig:
		if wheel_lock_recoil_remaining > 0.0:
			wheel_lock_recoil_remaining = max(0.0, wheel_lock_recoil_remaining - delta)
			var recoil_progress := 1.0 - wheel_lock_recoil_remaining / WHEEL_LOCK_RECOIL_DURATION
			wheel_lock_rig.position = _wheel_lock_base_position() + Vector3(0.0, 0.015, sin(recoil_progress * PI) * 0.17)
			wheel_lock_rig.rotation_degrees.x = sin(recoil_progress * PI) * -14.0
			if wheel_lock_recoil_remaining <= 0.0:
				weapon_animation_finished.emit("wheel_lock")
		elif wheel_lock_reload_remaining > 0.0:
			wheel_lock_reload_remaining = max(0.0, wheel_lock_reload_remaining - delta)
			var reload_progress := 1.0 - wheel_lock_reload_remaining / WHEEL_LOCK_RELOAD_DURATION
			var reload_arc := sin(reload_progress * PI)
			wheel_lock_rig.position = _wheel_lock_base_position() + Vector3(0.09 * reload_arc, -0.11 * reload_arc, 0.10 * reload_arc)
			wheel_lock_rig.rotation_degrees = Vector3(24.0 * reload_arc, 0.0, -31.0 * reload_arc)
			if wheel_lock_reload_remaining <= 0.0:
				wheel_lock_rig.position = _wheel_lock_base_position()
				wheel_lock_rig.rotation_degrees = Vector3.ZERO
				weapon_animation_finished.emit("wheel_lock_reload")
				reload_finished.emit()
		else:
			wheel_lock_rig.position = wheel_lock_rig.position.lerp(_wheel_lock_base_position(), minf(1.0, delta * ADS_BLEND_SPEED))
			wheel_lock_rig.rotation_degrees = wheel_lock_rig.rotation_degrees.lerp(Vector3.ZERO, minf(1.0, delta * ADS_BLEND_SPEED))
	if cutlass_rig:
		if cutlass_swing_remaining > 0.0:
			cutlass_swing_remaining = max(0.0, cutlass_swing_remaining - delta)
			var swing_progress := 1.0 - cutlass_swing_remaining / CUTLASS_SWING_DURATION
			var swing_angle := 30.0 if swing_progress < 0.32 else lerpf(30.0, -104.0, (swing_progress - 0.32) / 0.68)
			cutlass_rig.rotation_degrees = Vector3(0, 0, swing_angle)
			if cutlass_swing_remaining <= 0.0:
				cutlass_rig.rotation_degrees = Vector3(8, 0, -18)
				weapon_animation_finished.emit("cutlass")
		else:
			cutlass_rig.position = cutlass_rig.position.lerp(_cutlass_base_position(), minf(1.0, delta * ADS_BLEND_SPEED))

func _update_ads_presentation(delta: float) -> void:
	ads_blend = move_toward(ads_blend, 1.0 if ads_requested else 0.0, delta * ADS_BLEND_SPEED)
	if is_instance_valid(fps_camera):
		fps_camera.fov = lerpf(fps_camera.fov, lerpf(REST_FOV, ADS_FOV, ads_blend), minf(1.0, delta * ADS_BLEND_SPEED))

func _wheel_lock_base_position() -> Vector3:
	return WHEEL_LOCK_REST_POSITION.lerp(WHEEL_LOCK_REST_POSITION + WHEEL_LOCK_ADS_OFFSET, ads_blend)

func _cutlass_base_position() -> Vector3:
	return CUTLASS_REST_POSITION.lerp(CUTLASS_REST_POSITION + CUTLASS_ADS_OFFSET, ads_blend)

func _set_touch_fire_held(held: bool) -> void:
	touch_fire_held = held

func set_ads_requested(value: bool) -> void:
	if ads_requested == value:
		return
	ads_requested = value
	ads_changed.emit(ads_requested)

func is_aiming_down_sights() -> bool:
	return ads_requested

func is_reloading() -> bool:
	return wheel_lock_recoil_remaining > 0.0 or wheel_lock_reload_remaining > 0.0

func apply_move_intent(intent: Vector3, delta: float) -> void:
	var planar := Vector3(intent.x, 0, intent.z)
	if planar.length() > 1.0:
		planar = planar.normalized()
	velocity.x = planar.x * move_speed + knockback_velocity.x
	velocity.z = planar.z * move_speed + knockback_velocity.z
	var before := global_position
	move_and_slide()
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)
	if not is_on_wall():
		last_safe_position = global_position
	elif global_position.distance_to(before) < 0.001:
		velocity = Vector3.ZERO

func begin_dodge() -> bool:
	if dodge_remaining > 0.0:
		return false
	dodge_remaining = dodge_duration
	dodge_started.emit()
	return true

func is_dodging() -> bool:
	return dodge_remaining > 0.0

func take_enemy_hit(amount: int, impact_position: Vector3 = Vector3.ZERO, impact_force: float = knockback_force) -> Dictionary:
	if amount <= 0:
		return {"accepted": false, "reason": "invalid", "vitality": vitality}
	if is_dodging():
		enemy_hit_resolved.emit(amount, true, vitality)
		return {"accepted": true, "reason": "dodged", "vitality": vitality, "knockback": Vector3.ZERO}
	vitality = max(0, vitality - amount)
	var away := global_position - impact_position
	away.y = 0.0
	if away.length() < 0.01:
		away = -global_transform.basis.z
	away = away.normalized()
	knockback_velocity = away * max(0.0, impact_force)
	knockback_applied.emit(knockback_velocity)
	enemy_hit_resolved.emit(amount, false, vitality)
	return {"accepted": true, "reason": "hit", "vitality": vitality, "knockback": knockback_velocity}

func move_for_test(intent: Vector3, delta: float) -> Vector3:
	apply_move_intent(intent, delta)
	return global_position

func apply_look_delta(look_delta: Vector2) -> void:
	if look_delta.length_squared() <= 0.0001:
		return
	rotation.y -= look_delta.x * LOOK_SENSITIVITY * aim_sensitivity
	var vertical_direction := 1.0 if aim_invert_y else -1.0
	camera_pitch = clampf(camera_pitch + look_delta.y * LOOK_SENSITIVITY * aim_sensitivity * vertical_direction, deg_to_rad(-62.0), deg_to_rad(58.0))
	if is_instance_valid(fps_pitch_pivot):
		fps_pitch_pivot.rotation.x = camera_pitch

func set_aim_sensitivity(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, MIN_AIM_SENSITIVITY, MAX_AIM_SENSITIVITY)
	if is_equal_approx(aim_sensitivity, clamped):
		return
	aim_sensitivity = clamped
	if persist:
		save_aim_preferences()
	aim_preferences_changed.emit(aim_sensitivity, aim_invert_y)

func set_aim_invert_y(value: bool, persist: bool = true) -> void:
	if aim_invert_y == value:
		return
	aim_invert_y = value
	if persist:
		save_aim_preferences()
	aim_preferences_changed.emit(aim_sensitivity, aim_invert_y)

func load_aim_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(AIM_SETTINGS_PATH) != OK:
		return
	aim_sensitivity = clampf(float(config.get_value("aim", "sensitivity", DEFAULT_AIM_SENSITIVITY)), MIN_AIM_SENSITIVITY, MAX_AIM_SENSITIVITY)
	aim_invert_y = bool(config.get_value("aim", "invert_y", false))
	aim_preferences_changed.emit(aim_sensitivity, aim_invert_y)

func save_aim_preferences() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall"))
	var config := ConfigFile.new()
	config.set_value("aim", "sensitivity", aim_sensitivity)
	config.set_value("aim", "invert_y", aim_invert_y)
	config.save(AIM_SETTINGS_PATH)

func get_fps_camera() -> Camera3D:
	return fps_camera

func is_first_person() -> bool:
	return is_instance_valid(fps_camera)

func _build_first_person_rig() -> void:
	fps_pitch_pivot = Node3D.new()
	fps_pitch_pivot.name = "FirstPersonPitchPivot"
	fps_pitch_pivot.position = Vector3(0, 1.46, 0)
	add_child(fps_pitch_pivot)
	fps_camera = Camera3D.new()
	fps_camera.name = "FirstPersonCamera"
	fps_camera.current = true
	fps_camera.fov = REST_FOV
	fps_camera.near = 0.03
	fps_pitch_pivot.add_child(fps_camera)
	fps_viewmodel = Node3D.new()
	fps_viewmodel.name = "BloodwakeViewmodel"
	fps_camera.add_child(fps_viewmodel)
	cutlass_rig = Node3D.new()
	cutlass_rig.name = "CutlassAnimationRig"
	cutlass_rig.position = CUTLASS_REST_POSITION
	cutlass_rig.rotation_degrees = Vector3(8, 0, -18)
	fps_viewmodel.add_child(cutlass_rig)
	var blade := BoxMesh.new()
	blade.size = Vector3(0.055, 0.62, 0.055)
	_append_captain_part(cutlass_rig, "BoardingCutlass", blade, Vector3(0, 0.18, 0), _captain_material(Color("C5A87C"), 0.82, 0.04), Vector3(0, 0, 8))
	var guard := TorusMesh.new()
	guard.inner_radius = 0.10
	guard.outer_radius = 0.14
	_append_captain_part(cutlass_rig, "BrassCutlassGuard", guard, Vector3(0, -0.08, 0), _captain_material(Color("B68A39"), 0.92, 0.12), Vector3(90, 0, 0))
	wheel_lock_rig = Node3D.new()
	wheel_lock_rig.name = "WheelLockAnimationRig"
	wheel_lock_rig.position = WHEEL_LOCK_REST_POSITION
	fps_viewmodel.add_child(wheel_lock_rig)
	var barrel := CylinderMesh.new()
	barrel.top_radius = 0.055
	barrel.bottom_radius = 0.09
	barrel.height = 0.62
	barrel.radial_segments = 10
	_append_captain_part(wheel_lock_rig, "WheelLockBarrel", barrel, Vector3(0, 0, -0.24), _captain_material(Color("1D2428"), 0.78, 0.04), Vector3(90, 0, 0))
	var lock := CylinderMesh.new()
	lock.top_radius = 0.12
	lock.bottom_radius = 0.12
	lock.height = 0.09
	lock.radial_segments = 10
	_append_captain_part(wheel_lock_rig, "WheelLockMechanism", lock, Vector3(0, 0.05, 0.04), _captain_material(Color("B68A39"), 0.9, 0.08), Vector3(90, 0, 0))

func _build_bloodwake_visual() -> void:
	var visual := Node3D.new()
	visual.name = "BloodwakeCaptainVisual"
	visual.visible = false
	add_child(visual)
	var coat := CapsuleMesh.new()
	coat.radius = 0.34
	coat.height = 1.35
	coat.radial_segments = 8
	_append_captain_part(visual, "OxbloodCoat", coat, Vector3(0, 0.75, 0), _captain_material(Color("351316"), 0.18, 0.0))
	var head := SphereMesh.new()
	head.radius = 0.27
	head.height = 0.54
	head.radial_segments = 8
	_append_captain_part(visual, "VampireCaptainHead", head, Vector3(0, 1.55, -0.02), _captain_material(Color("C9B49B"), 0.04, 0.0))
	var brim := CylinderMesh.new()
	brim.top_radius = 0.5
	brim.bottom_radius = 0.5
	brim.height = 0.07
	brim.radial_segments = 12
	_append_captain_part(visual, "TricornBrim", brim, Vector3(0, 1.79, 0), _captain_material(Color("100D0A"), 0.12, 0.0))
	var crown := CylinderMesh.new()
	crown.top_radius = 0.2
	crown.bottom_radius = 0.4
	crown.height = 0.32
	crown.radial_segments = 8
	_append_captain_part(visual, "TricornCrown", crown, Vector3(0, 1.96, 0), _captain_material(Color("17110D"), 0.15, 0.0))
	var astrolabe := TorusMesh.new()
	astrolabe.inner_radius = 0.11
	astrolabe.outer_radius = 0.15
	_append_captain_part(visual, "BrassAstrolabe", astrolabe, Vector3(0, 0.96, -0.35), _captain_material(Color("B68A39"), 0.72, 0.25), Vector3(90, 0, 0))
	var holstered_cutlass := Node3D.new()
	holstered_cutlass.name = "HolsteredCutlass"
	holstered_cutlass.position = Vector3(0.48, 0.72, -0.03)
	holstered_cutlass.rotation_degrees = Vector3(0, 0, -32)
	visual.add_child(holstered_cutlass)
	var blade := BoxMesh.new()
	blade.size = Vector3(0.07, 0.75, 0.07)
	_append_captain_part(holstered_cutlass, "BoardingCutlass", blade, Vector3.ZERO, _captain_material(Color("B89B73"), 0.78, 0.0))
	var holstered_wheel_lock := Node3D.new()
	holstered_wheel_lock.name = "HolsteredWheelLock"
	holstered_wheel_lock.position = Vector3(-0.42, 1.13, -0.44)
	visual.add_child(holstered_wheel_lock)
	var barrel := CylinderMesh.new()
	barrel.top_radius = 0.07
	barrel.bottom_radius = 0.10
	barrel.height = 0.52
	barrel.radial_segments = 8
	_append_captain_part(holstered_wheel_lock, "WheelLockBarrel", barrel, Vector3(0, 0, -0.18), _captain_material(Color("2A2017"), 0.65, 0.0), Vector3(90, 0, 0))
	var lock := CylinderMesh.new()
	lock.top_radius = 0.11
	lock.bottom_radius = 0.11
	lock.height = 0.08
	lock.radial_segments = 10
	_append_captain_part(holstered_wheel_lock, "WheelLockMechanism", lock, Vector3(0, 0.04, 0.05), _captain_material(Color("B68A39"), 0.82, 0.06), Vector3(90, 0, 0))

func _append_captain_part(parent: Node3D, part_name: String, mesh: PrimitiveMesh, local_position: Vector3, material: StandardMaterial3D, rotation_value: Vector3 = Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = local_position
	part.rotation_degrees = rotation_value
	part.material_override = material
	parent.add_child(part)

func _captain_material(color: Color, metallic: float, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.42
	material.emission_enabled = emission > 0.0
	material.emission = color
	material.emission_energy_multiplier = emission
	return material
