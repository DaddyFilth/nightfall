class_name CampaignBossHazard
extends Node3D

signal windup_started(hazard_name: String, duration: float)
signal resolved(hazard_name: String, hits: int)

var profile: Dictionary = {}
var tracked_player: Node3D
var active := false
var cycle_remaining := 2.4
var windup_remaining := 0.0
var markers: Array[MeshInstance3D] = []
var marker_materials: Array[StandardMaterial3D] = []
var marker_positions: Array[Vector3] = []
var hazard_label: Label3D

func configure(next_profile: Dictionary) -> void:
	profile = next_profile.duplicate(true)

func track_player(player: Node3D) -> void:
	tracked_player = player

func set_active(value: bool) -> void:
	active = value
	visible = value

func _ready() -> void:
	name = "BossHazard_%s" % str(profile.get("mode", "tide"))
	_build_hazard()
	set_active(false)

func _process(delta: float) -> void:
	if not active or not is_instance_valid(tracked_player):
		return
	if windup_remaining > 0.0:
		windup_remaining = maxf(0.0, windup_remaining - delta)
		_update_windup_visual()
		if windup_remaining <= 0.0:
			_resolve_hazard()
		return
	cycle_remaining = maxf(0.0, cycle_remaining - delta)
	if cycle_remaining <= 0.0:
		_start_hazard()

func trigger_hazard() -> void:
	if active and windup_remaining <= 0.0:
		_start_hazard()

func force_resolve() -> void:
	if windup_remaining > 0.0:
		windup_remaining = 0.0
		_resolve_hazard()

func _start_hazard() -> void:
	_reposition_markers()
	windup_remaining = 0.9
	global_position = marker_positions[0] if not marker_positions.is_empty() else global_position
	windup_started.emit(str(profile.get("name", "ARENA HAZARD")), windup_remaining)
	_update_windup_visual()

func _resolve_hazard() -> void:
	var hits := 0
	var damage := int(profile.get("damage", 10))
	for index in marker_positions.size():
		if is_instance_valid(tracked_player) and tracked_player.global_position.distance_to(marker_positions[index]) <= 1.45:
			if tracked_player.has_method("take_enemy_hit"):
				tracked_player.call("take_enemy_hit", damage, marker_positions[index], 5.2)
				hits += 1
		_set_marker_energy(index, 1.25)
	cycle_remaining = float(profile.get("interval", 4.0))
	resolved.emit(str(profile.get("name", "ARENA HAZARD")), hits)

func _build_hazard() -> void:
	var count := clampi(int(profile.get("count", 3)), 2, 5)
	var accent: Color = profile.get("accent", Color("D93056")) as Color
	for index in count:
		var marker := MeshInstance3D.new()
		marker.name = "HazardTelegraph_%02d" % (index + 1)
		var mesh: PrimitiveMesh = TorusMesh.new()
		if str(profile.get("mode", "")) in ["lattice", "arc", "deckbreak"]:
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.78
			cylinder.bottom_radius = 0.9
			cylinder.height = 0.05
			mesh = cylinder
		marker.mesh = mesh
		marker.rotation_degrees.x = 90.0 if mesh is TorusMesh else 0.0
		var material := StandardMaterial3D.new()
		material.albedo_color = accent.darkened(0.25)
		material.emission_enabled = true
		material.emission = accent
		material.emission_energy_multiplier = 1.25
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		marker.material_override = material
		add_child(marker)
		markers.append(marker)
		marker_materials.append(material)
	var label := Label3D.new()
	label.name = "BossHazardLabel"
	label.text = str(profile.get("name", "ARENA HAZARD"))
	label.font_size = 28
	label.outline_size = 6
	label.modulate = Color("FFD1D9")
	label.position = Vector3(-2.2, 0.12, 0)
	add_child(label)
	hazard_label = label

func _reposition_markers() -> void:
	marker_positions.clear()
	var base := tracked_player.global_position
	var count := markers.size()
	for index in count:
		var angle := TAU * float(index) / float(count) + float(profile.get("damage", 10)) * 0.07
		var radius := 1.25 + float(index % 2) * 0.9
		var position := base + Vector3(cos(angle) * radius, 0.06, sin(angle) * radius)
		markers[index].global_position = position
		marker_positions.append(position)

func _update_windup_visual() -> void:
	var intensity := 4.6 + (1.0 - windup_remaining / 0.9) * 4.2
	for index in marker_materials.size():
		_set_marker_energy(index, intensity)
	if hazard_label:
		hazard_label.text = "DODGE // %s" % str(profile.get("name", "ARENA HAZARD"))

func _set_marker_energy(index: int, energy: float) -> void:
	if index >= 0 and index < marker_materials.size():
		marker_materials[index].emission_energy_multiplier = energy
