class_name HollowedActor
extends Node3D

enum AnimationState { IDLE, PURSUIT, ATTACK, HIT, DISSOLVE }

signal state_changed(state_name: String)

@export var accent: Color = Color("d93056")
@export var idle_offset: float = 0.0
var archetype := "privateer"
var archetype_label := "PRIVATEER"
var movement_speed := 0.78
var attack_damage := 9
var attack_range := 1.55
var attack_knockback := 4.2
var body_scale := 1.0
var phase := 0.0
var state_elapsed := 0.0
var animation_state := AnimationState.IDLE
var health := 100
var defeated := false
var model_root: Node3D
var halo: MeshInstance3D
var material_texture: GradientTexture1D
var cutlass: MeshInstance3D
var cutlass_rest_rotation := Vector3(0, 0, -28)
var attack_beacon: MeshInstance3D
var attack_beacon_material: StandardMaterial3D

func _ready() -> void:
	add_to_group("nightfall_enemy")
	material_texture = _create_hollowed_texture()
	model_root = Node3D.new()
	model_root.name = "TexturedHollowedMesh"
	add_child(model_root)
	_build_textured_mesh()
	halo = _ring()
	_build_hurtbox()
	scale = Vector3.ONE * body_scale

func configure_archetype(value: String) -> void:
	archetype = value
	match archetype:
		"harpoon_raider":
			archetype_label = "HARPOON RAIDER"
			accent = Color("B68A39")
			health = 90
			movement_speed = 0.98
			attack_damage = 10
			attack_range = 3.0
			attack_knockback = 5.6
			body_scale = 0.92
		"lantern_wisp":
			archetype_label = "LANTERN WISP"
			accent = Color("E7CB63")
			health = 64
			movement_speed = 1.34
			attack_damage = 8
			attack_range = 2.3
			attack_knockback = 3.8
			body_scale = 0.68
		"iron_abbot":
			archetype_label = "IRON ABBOT"
			accent = Color("8D2634")
			health = 175
			movement_speed = 0.56
			attack_damage = 16
			attack_range = 2.05
			attack_knockback = 7.4
			body_scale = 1.34
		"coffin_marine":
			archetype_label = "COFFIN MARINE"
			accent = Color("7A5C97")
			health = 140
			movement_speed = 0.72
			attack_damage = 14
			attack_range = 2.0
			attack_knockback = 6.3
			body_scale = 1.16
		"bell_tollkeeper":
			archetype_label = "BELL TOLLKEEPER"
			accent = Color("7F99A4")
			health = 108
			movement_speed = 1.1
			attack_damage = 15
			attack_range = 2.7
			attack_knockback = 5.1
			body_scale = 1.04
		"meridian_sentinel":
			archetype_label = "MERIDIAN SENTINEL"
			accent = Color("B24745")
			health = 120
			movement_speed = 1.0
			attack_damage = 16
			attack_range = 2.8
			attack_knockback = 6.0
			body_scale = 1.08
		"leviathan_guard":
			archetype_label = "LEVIATHAN GUARD"
			accent = Color("C7973A")
			health = 190
			movement_speed = 0.48
			attack_damage = 22
			attack_range = 2.3
			attack_knockback = 8.2
			body_scale = 1.4
		_:
			archetype = "privateer"
			archetype_label = "PRIVATEER"

func _process(delta: float) -> void:
	if not is_instance_valid(model_root) or not is_instance_valid(halo):
		return
	if defeated:
		state_elapsed += delta
		model_root.scale = Vector3.ONE * max(0.03, 1.0 - state_elapsed * 1.15)
		halo.scale = Vector3.ONE * max(0.03, 1.0 - state_elapsed * 1.5)
		return
	phase += delta
	state_elapsed += delta
	match animation_state:
		AnimationState.IDLE:
			model_root.position.y = sin(phase * 2.0 + idle_offset) * 0.07
			halo.scale = Vector3.ONE * (1.0 + sin(phase * 3.0 + idle_offset) * 0.04)
			if state_elapsed >= 2.2:
				_set_state(AnimationState.PURSUIT)
		AnimationState.PURSUIT:
			model_root.position.y = sin(phase * 4.0) * 0.035
			rotation.y += delta * 0.85
			model_root.scale = Vector3(1.04, 0.96, 1.04)
			if state_elapsed >= 1.25:
				_set_state(AnimationState.ATTACK)
		AnimationState.ATTACK:
			model_root.rotation.x = sin(state_elapsed * 13.0) * 0.12
			if cutlass:
				var strike_angle := 38.0 if state_elapsed < 0.22 else lerpf(38.0, -104.0, min(1.0, (state_elapsed - 0.22) / 0.25))
				cutlass.rotation_degrees = Vector3(0, 0, strike_angle)
			halo.scale = Vector3.ONE * (1.0 + sin(state_elapsed * 17.0) * 0.18)
			_update_attack_beacon()
			if state_elapsed >= 0.62:
				_set_state(AnimationState.IDLE)
		AnimationState.HIT:
			model_root.rotation.z = sin(state_elapsed * 24.0) * 0.22
			halo.scale = Vector3.ONE * 1.22
			if state_elapsed >= 0.28:
				_set_state(AnimationState.IDLE)

func take_projectile_hit(amount: int, _impact_position: Vector3) -> Dictionary:
	if defeated:
		return {"accepted": false, "defeated": true, "health": health, "state": animation_state_name()}
	health = max(0, health - clampi(amount, 0, 100))
	if health == 0:
		defeated = true
		_set_state(AnimationState.DISSOLVE)
	else:
		_set_state(AnimationState.HIT)
	return {"accepted": true, "defeated": defeated, "health": health, "state": animation_state_name()}

func animation_state_name() -> String:
	return ["idle", "pursuit", "attack", "hit", "dissolve"][animation_state]

func _set_state(next_state: AnimationState) -> void:
	animation_state = next_state
	state_elapsed = 0.0
	if is_instance_valid(model_root):
		model_root.rotation = Vector3.ZERO
		model_root.scale = Vector3.ONE
	if cutlass:
		cutlass.rotation_degrees = cutlass_rest_rotation
	if is_instance_valid(attack_beacon):
		attack_beacon.visible = next_state == AnimationState.ATTACK
		attack_beacon.scale = Vector3.ONE
	state_changed.emit(animation_state_name())

func _build_textured_mesh() -> void:
	var torso := CapsuleMesh.new()
	torso.radius = 0.45
	torso.height = 1.65
	torso.radial_segments = 8
	torso.rings = 1
	_append_mesh("Torso", torso, Vector3(0, 0.92, 0), _material(Color("342016"), 0.32, 0.12))
	var coat_tail := BoxMesh.new()
	coat_tail.size = Vector3(0.88, 0.86, 0.18)
	_append_mesh("TornDeckCoat", coat_tail, Vector3(0, 0.66, 0.31), _material(Color("24130F"), 0.24, 0.04), Vector3(6, 0, 0))
	var head := SphereMesh.new()
	head.radius = 0.39
	head.height = 0.72
	head.radial_segments = 8
	head.rings = 4
	_append_mesh("MaskedHead", head, Vector3(0, 1.96, -0.03), _material(Color("9C856D"), 0.18, 0.08))
	var brim := CylinderMesh.new()
	brim.top_radius = 0.48
	brim.bottom_radius = 0.48
	brim.height = 0.06
	brim.radial_segments = 10
	_append_mesh("PrivateerTricornBrim", brim, Vector3(0, 2.21, 0), _material(Color("110C09"), 0.18, 0.0))
	var crown := CylinderMesh.new()
	crown.top_radius = 0.15
	crown.bottom_radius = 0.37
	crown.height = 0.29
	crown.radial_segments = 7
	_append_mesh("PrivateerTricornCrown", crown, Vector3(0, 2.36, 0), _material(Color("1C110D"), 0.2, 0.0))
	for side in [-1.0, 1.0]:
		var arm := CylinderMesh.new()
		arm.top_radius = 0.16
		arm.bottom_radius = 0.22
		arm.height = 1.15
		arm.radial_segments = 7
		_append_mesh("Arm_%s" % side, arm, Vector3(side * 0.54, 1.12, 0.0), _material(Color("3B2118"), 0.34, 0.1), Vector3(0, 0, side * 18.0))
		var eye := SphereMesh.new()
		eye.radius = 0.075
		eye.height = 0.15
		eye.radial_segments = 6
		eye.rings = 3
		_append_mesh("Eye_%s" % side, eye, Vector3(side * 0.15, 2.01, -0.37), _emissive_material(accent, 3.2))
	var shard := PrismMesh.new()
	shard.left_to_right = 0.56
	shard.size = Vector3(0.58, 0.9, 0.3)
	_append_mesh("BackShard", shard, Vector3(0, 1.33, 0.38), _emissive_material(accent, 1.5), Vector3(0.3, 0.1, 0))
	var cutlass := BoxMesh.new()
	cutlass.size = Vector3(0.06, 0.78, 0.08)
	self.cutlass = _append_mesh("RustCutlass", cutlass, Vector3(0.72, 0.92, -0.05), _material(Color("A87B3B"), 0.7, 0.08), cutlass_rest_rotation)
	attack_beacon = MeshInstance3D.new()
	attack_beacon.name = "PrivateerAttackBeacon"
	var beacon_mesh := TorusMesh.new()
	beacon_mesh.inner_radius = 0.28
	beacon_mesh.outer_radius = 0.38
	attack_beacon.mesh = beacon_mesh
	attack_beacon.position = Vector3(0, 2.16, -0.34)
	attack_beacon.rotation_degrees.x = 90.0
	attack_beacon_material = _emissive_material(Color("D93056"), 5.8)
	attack_beacon.material_override = attack_beacon_material
	attack_beacon.visible = false
	model_root.add_child(attack_beacon)
	var archetype_mark := MeshInstance3D.new()
	archetype_mark.name = "ArchetypeMark_%s" % archetype
	var mark_mesh := SphereMesh.new()
	mark_mesh.radius = 0.22 + body_scale * 0.12
	mark_mesh.height = 0.44 + body_scale * 0.18
	archetype_mark.mesh = mark_mesh
	archetype_mark.position = Vector3(0, 2.42, 0.05)
	archetype_mark.material_override = _emissive_material(accent, 2.4)
	model_root.add_child(archetype_mark)

func _update_attack_beacon() -> void:
	if not is_instance_valid(attack_beacon):
		return
	var pulse := 0.5 + 0.5 * sin(state_elapsed * 24.0)
	attack_beacon.scale = Vector3.ONE * (1.10 + pulse * 0.42)
	if attack_beacon_material:
		attack_beacon_material.emission_energy_multiplier = 5.8 + pulse * 4.2

func _append_mesh(part_name: String, mesh: PrimitiveMesh, local_position: Vector3, material: StandardMaterial3D, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = local_position
	part.rotation_degrees = rotation_degrees
	part.material_override = material
	model_root.add_child(part)
	return part

func _ring() -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = "EclipseHalo"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.44
	mesh.outer_radius = 0.48
	mesh.material = _emissive_material(accent, 2.6)
	ring.mesh = mesh
	ring.position = Vector3(0, 1.38, 0)
	ring.rotation_degrees.x = 90.0
	add_child(ring)
	return ring

func _build_hurtbox() -> void:
	var hurtbox := Area3D.new()
	hurtbox.name = "HollowedHurtbox"
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 0
	hurtbox.set_meta("nightfall_damage_target", self)
	var shape_node := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.43
	shape.height = 2.08
	shape_node.shape = shape
	shape_node.position.y = 1.0
	hurtbox.add_child(shape_node)
	add_child(hurtbox)

func _create_hollowed_texture() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.28, 0.5, 0.72, 1.0])
	gradient.colors = PackedColorArray([Color("080604"), Color("2B1A12"), accent, Color("6E2830"), Color("0C1513")])
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	texture.width = 256
	return texture

func _material(color: Color, metallic: float, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.albedo_texture = material_texture
	material.metallic = metallic
	material.roughness = 0.42
	material.emission_enabled = emission > 0.0
	material.emission = accent
	material.emission_energy_multiplier = emission
	return material

func _emissive_material(color: Color, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	material.roughness = 0.24
	return material
