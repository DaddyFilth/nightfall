class_name ObservatoryConductor
extends Node3D

signal phase_changed(phase: int, mechanic: String)
signal damage_resolved(amount: int, vitality: int)
signal vitality_changed(vitality: int, maximum: int, phase: int)
signal attack_windup_started(attack_name: String, duration: float, phase: int)
signal attack_resolved(results: Array[Dictionary])
signal defeated(reward: Dictionary)

@export_enum("last_platform", "static_trail") var branch := "last_platform"
var max_vitality := 360
var vitality := 360
var phase := 1
var is_defeated := false
var shell: MeshInstance3D
var telegraph_ring: MeshInstance3D
var telegraph_label: Label
var hurtbox: StaticBody3D
var attack_area: Area3D
var attack_shape: SphereShape3D
var tracked_player: Node3D
var shell_material: StandardMaterial3D
var telegraph_material: StandardMaterial3D
var attack_range := 2.5
var attack_damage := 16
var attack_knockback := 8.5
var attack_windup_duration := 0.72
var attack_windup_remaining := 0.0
var is_winding_up := false
var boss_title := "DROWNED ADMIRAL"
var boss_accent := Color("4A877A")
var profile_attacks: Array[String] = []
var base_attack_damage := 16

func _ready() -> void:
	name = "ObservatoryConductor"
	_build_visual()
	_build_hurtbox()
	_build_phase_telegraph()
	_build_attack_hitbox()
	phase_changed.connect(_update_phase_telegraph)
	_update_phase_telegraph(phase, current_mechanic())
	phase_changed.emit(phase, current_mechanic())
	vitality_changed.emit(vitality, max_vitality, phase)

func configure_branch(value: String) -> void:
	branch = value if value == "last_platform" or value == "static_trail" else "last_platform"

func configure_campaign_profile(profile: Dictionary) -> void:
	boss_title = str(profile.get("title", boss_title))
	boss_accent = profile.get("accent", boss_accent) as Color
	max_vitality = max(120, int(profile.get("vitality", max_vitality)))
	vitality = max_vitality
	base_attack_damage = max(1, int(profile.get("damage", base_attack_damage)))
	attack_damage = base_attack_damage
	var attacks: Array = profile.get("attacks", [])
	profile_attacks.clear()
	for attack in attacks:
		profile_attacks.append(str(attack))

func track_player(player: Node3D) -> void:
	tracked_player = player

func _physics_process(delta: float) -> void:
	if is_defeated or not is_instance_valid(tracked_player) or not is_instance_valid(shell):
		return
	var desired := shell.position
	desired.x = clamp(tracked_player.global_position.x, -2.6, 2.6)
	shell.position = shell.position.move_toward(desired, delta * 0.8)
	_sync_combat_nodes()
	if is_winding_up:
		attack_windup_remaining = max(0.0, attack_windup_remaining - delta)
		_update_attack_windup_visual()
		if attack_windup_remaining <= 0.0:
			_resolve_attack()

func trigger_attack() -> Array[Dictionary]:
	if is_defeated or not attack_area or is_winding_up:
		return []
	is_winding_up = true
	attack_windup_remaining = attack_windup_duration
	attack_windup_started.emit(attack_name(), attack_windup_duration, phase)
	_update_attack_windup_visual()
	return []

func attack_name() -> String:
	if profile_attacks.size() >= phase:
		return profile_attacks[phase - 1]
	if branch == "last_platform":
		return ["BEACON BREAK", "MIRROR SURGE", "LAST TRAIN IMPACT"][phase - 1]
	return ["PULSE BREAK", "LATTICE SHEAR", "CIPHER COLLAPSE"][phase - 1]

func _resolve_attack() -> Array[Dictionary]:
	is_winding_up = false
	var results: Array[Dictionary] = []
	var targets: Array[Node3D] = []
	for body in attack_area.get_overlapping_bodies():
		if body is Node3D and body.has_method("take_enemy_hit"):
			targets.append(body)
	if tracked_player and tracked_player.has_method("take_enemy_hit") and not targets.has(tracked_player):
		if tracked_player.global_position.distance_to(attack_area.global_position) <= attack_range + 0.5:
			targets.append(tracked_player)
	for target in targets:
		results.append(target.call("take_enemy_hit", attack_damage, attack_area.global_position, attack_knockback))
	attack_resolved.emit(results)
	_update_phase_telegraph(phase, current_mechanic())
	return results

func apply_damage(amount: int) -> Dictionary:
	if is_defeated or amount <= 0:
		return {"accepted": false, "reason": "inactive", "vitality": vitality}
	vitality = max(0, vitality - amount)
	damage_resolved.emit(amount, vitality)
	var next_phase := phase_for_vitality()
	if next_phase != phase and vitality > 0:
		phase = next_phase
		phase_changed.emit(phase, current_mechanic())
	if vitality == 0:
		is_defeated = true
		vitality_changed.emit(vitality, max_vitality, phase)
		var reward := completion_reward()
		defeated.emit(reward)
		return {"accepted": true, "reason": "defeated", "vitality": vitality, "reward": reward}
	vitality_changed.emit(vitality, max_vitality, phase)
	return {"accepted": true, "reason": "hit", "vitality": vitality, "phase": phase, "mechanic": current_mechanic()}

func phase_for_vitality() -> int:
	if vitality > int(float(max_vitality) * 0.66):
		return 1
	if vitality > int(float(max_vitality) * 0.33):
		return 2
	return 3

func current_mechanic() -> String:
	if branch == "last_platform":
		return ["BEACON SANCTUARY", "EVACUATION MIRRORS", "LAST TRAIN REVERSAL"][phase - 1]
	return ["THIRTEENTH PULSE", "LATTICE SCISSION", "CIPHER OVERLOAD"][phase - 1]

func completion_reward() -> Dictionary:
	if branch == "last_platform":
		return {"title": "CIVIC WAYFINDER", "cosmetic": "Platform Keeper Banner", "advantage": false}
	return {"title": "RELAY BREAKER", "cosmetic": "Cipher Halo Frame", "advantage": false}

func take_projectile_hit(amount: int, impact_position: Vector3) -> Dictionary:
	var result := apply_damage(amount)
	if result["accepted"]:
		_flash_hit(impact_position)
	return result

func _build_visual() -> void:
	shell = MeshInstance3D.new()
	shell.name = "DrownedAdmiralShell"
	var mesh := CapsuleMesh.new()
	mesh.radius = 1.45
	mesh.height = 4.3
	shell_material = StandardMaterial3D.new()
	shell_material.albedo_color = boss_accent.darkened(0.58)
	shell_material.metallic = 0.52
	shell_material.roughness = 0.34
	shell_material.emission_enabled = true
	shell_material.emission = boss_accent
	shell_material.emission_energy_multiplier = 1.25
	mesh.material = shell_material
	shell.mesh = mesh
	shell.position = Vector3(0, 2.5, -4.8)
	add_child(shell)
	var head := SphereMesh.new()
	head.radius = 0.54
	head.height = 1.08
	head.radial_segments = 10
	_append_admiral_part("AdmiralVampireHead", head, Vector3(0, 1.68, -0.12), _admiral_material(Color("B4A08A"), 0.08, 0.0))
	var brim := CylinderMesh.new()
	brim.top_radius = 1.16
	brim.bottom_radius = 1.16
	brim.height = 0.13
	brim.radial_segments = 14
	_append_admiral_part("AdmiralTricornBrim", brim, Vector3(0, 2.18, 0), _admiral_material(Color("100B08"), 0.22, 0.0))
	var crown := CylinderMesh.new()
	crown.top_radius = 0.38
	crown.bottom_radius = 0.85
	crown.height = 0.62
	crown.radial_segments = 8
	_append_admiral_part("AdmiralTricornCrown", crown, Vector3(0, 2.48, 0), _admiral_material(Color("1B110B"), 0.28, 0.0))
	var astrolabe := TorusMesh.new()
	astrolabe.inner_radius = 0.36
	astrolabe.outer_radius = 0.48
	_append_admiral_part("AdmiralAstrolabe", astrolabe, Vector3(0, 0.4, -1.43), _admiral_material(Color("B68A39"), 0.8, 0.35), Vector3(90, 0, 0))
	var epaulette := SphereMesh.new()
	epaulette.radius = 0.36
	epaulette.height = 0.46
	epaulette.radial_segments = 8
	for side in [-1.0, 1.0]:
		_append_admiral_part("AdmiralEpaulette_%s" % side, epaulette, Vector3(side * 1.25, 0.85, 0), _admiral_material(Color("A67B33"), 0.76, 0.1))
	var cutlass := BoxMesh.new()
	cutlass.size = Vector3(0.12, 2.35, 0.12)
	_append_admiral_part("AdmiralCutlass", cutlass, Vector3(1.72, -0.24, -0.06), _admiral_material(Color("C3A56E"), 0.84, 0.0), Vector3(0, 0, -28))

func _append_admiral_part(part_name: String, mesh: PrimitiveMesh, local_position: Vector3, material: StandardMaterial3D, rotation_value: Vector3 = Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = local_position
	part.rotation_degrees = rotation_value
	part.material_override = material
	shell.add_child(part)

func _admiral_material(color: Color, metallic: float, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.34
	material.emission_enabled = emission > 0.0
	material.emission = color
	material.emission_energy_multiplier = emission
	return material

func _build_hurtbox() -> void:
	var hurtbox := StaticBody3D.new()
	hurtbox.name = "ConductorHurtbox"
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 0
	hurtbox.position = Vector3(0, 2.5, -4.8)
	hurtbox.set_meta("nightfall_damage_target", self)
	var collider := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 2.25
	collider.shape = shape
	hurtbox.add_child(collider)
	add_child(hurtbox)
	self.hurtbox = hurtbox

func _build_attack_hitbox() -> void:
	attack_area = Area3D.new()
	attack_area.name = "ConductorAttackHitbox"
	attack_area.collision_layer = 0
	attack_area.collision_mask = 2
	attack_area.monitoring = true
	attack_area.position = Vector3(0, 1.0, -2.7)
	var collider := CollisionShape3D.new()
	attack_shape = SphereShape3D.new()
	attack_shape.radius = attack_range
	collider.shape = attack_shape
	attack_area.add_child(collider)
	add_child(attack_area)

func _build_phase_telegraph() -> void:
	telegraph_ring = MeshInstance3D.new()
	telegraph_ring.name = "ConductorPhaseTelegraph"
	var ring := TorusMesh.new()
	ring.inner_radius = 2.5
	ring.outer_radius = 2.72
	telegraph_ring.mesh = ring
	telegraph_ring.position = Vector3(0, 0.2, -4.8)
	telegraph_ring.rotation_degrees.x = 90.0
	add_child(telegraph_ring)
	var layer := CanvasLayer.new()
	layer.name = "ConductorTelegraphUI"
	telegraph_label = Label.new()
	telegraph_label.position = Vector2(24, 52)
	telegraph_label.add_theme_font_size_override("font_size", 16)
	telegraph_label.add_theme_color_override("font_color", Color("F5F0E9"))
	telegraph_label.add_theme_color_override("font_outline_color", Color("08070C"))
	telegraph_label.add_theme_constant_override("outline_size", 5)
	layer.add_child(telegraph_label)
	add_child(layer)

func _update_phase_telegraph(next_phase: int, mechanic: String) -> void:
	if telegraph_label:
		telegraph_label.text = boss_title + " // PHASE " + str(next_phase) + " // " + mechanic + " // DODGE WINDOW READY"
	if shell:
		shell.scale = Vector3.ONE
	attack_range = 2.5 + float(next_phase - 1) * 0.55
	attack_damage = base_attack_damage + (next_phase - 1) * 5
	attack_knockback = 8.5 + float(next_phase - 1) * 1.2
	if attack_shape:
		attack_shape.radius = attack_range
	if telegraph_ring:
		telegraph_ring.scale = Vector3.ONE
		telegraph_material = StandardMaterial3D.new()
		var color := boss_accent
		if next_phase == 2:
			color = Color("B68A39")
		elif next_phase == 3:
			color = Color("8D2634")
		telegraph_material.albedo_color = color
		telegraph_material.emission_enabled = true
		telegraph_material.emission = color
		telegraph_material.emission_energy_multiplier = 2.4
		telegraph_ring.mesh.material = telegraph_material

func _update_attack_windup_visual() -> void:
	if not shell:
		return
	var progress: float = 1.0 - (attack_windup_remaining / maxf(attack_windup_duration, 0.01))
	var scale_value := 1.0 + 0.18 * sin(progress * PI)
	shell.scale = Vector3.ONE * scale_value
	if shell_material:
		shell_material.emission = Color("D93056")
		shell_material.emission_energy_multiplier = 3.6 + progress * 2.8
	if telegraph_ring:
		telegraph_ring.scale = Vector3.ONE * (1.0 + 0.58 * progress)
		if telegraph_material:
			telegraph_material.emission = Color("D93056")
			telegraph_material.emission_energy_multiplier = 5.5 + progress * 3.5
	if telegraph_label:
		telegraph_label.add_theme_color_override("font_color", Color("FFD1D9"))
		telegraph_label.text = boss_title + " // INCOMING " + attack_name() + " // DODGE NOW // " + str(ceil(attack_windup_remaining * 10.0) / 10.0) + "s"

func _flash_hit(_impact_position: Vector3) -> void:
	if shell and shell.mesh and shell.mesh.material is StandardMaterial3D:
		var material := shell.mesh.material as StandardMaterial3D
		material.emission = Color("F5F0E9")
		material.emission_energy_multiplier = 3.2
		get_tree().create_timer(0.08).timeout.connect(func() -> void: _update_shell_emission())

func _update_shell_emission() -> void:
	if shell and shell.mesh and shell.mesh.material is StandardMaterial3D:
		var material := shell.mesh.material as StandardMaterial3D
		material.emission = boss_accent
		material.emission_energy_multiplier = 1.25
	if telegraph_label:
		telegraph_label.add_theme_color_override("font_color", Color("F5F0E9"))

func _sync_combat_nodes() -> void:
	if not is_instance_valid(shell):
		return
	if is_instance_valid(hurtbox):
		hurtbox.position = shell.position
	if is_instance_valid(attack_area):
		attack_area.position = shell.position + Vector3(0, -1.5, 2.1)
