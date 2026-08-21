class_name CampaignPuzzleGate
extends Node3D

signal solved(level_id: int, checkpoint_index: int)

var level_id := 1
var checkpoint_index := 1
var profile: Dictionary = {}
var puzzle_mode := "sequence"
var sequence: Array[int] = []
var required_indices: Array[int] = []
var charge_hits_required := 1
var progress := 0
var complete := false
var rune_positions: Array[Vector3] = []
var rune_materials: Array[StandardMaterial3D] = []
var status_label: Label3D

func configure(next_level_id: int, next_checkpoint_index: int, next_profile: Dictionary) -> void:
	level_id = next_level_id
	checkpoint_index = next_checkpoint_index
	profile = next_profile.duplicate(true)
	puzzle_mode = str(profile.get("mode", "sequence"))
	var source_sequence: Array = profile.get("sequence", [])
	sequence.clear()
	for rune_index in source_sequence:
		sequence.append(int(rune_index))
	var source_required: Array = profile.get("requiredSet", [])
	required_indices.clear()
	for rune_index in source_required:
		required_indices.append(int(rune_index))
	charge_hits_required = max(1, int(profile.get("hitsRequired", 1)))

func _ready() -> void:
	name = "PuzzleGate_%02d_%02d" % [level_id, checkpoint_index]
	_build_gate()

func take_projectile_hit(_amount: int, impact_position: Vector3) -> Dictionary:
	if complete or rune_positions.is_empty():
		return {"accepted": false, "reason": "inactive"}
	var selected_index := _nearest_rune_index(impact_position)
	match puzzle_mode:
		"route":
			return _resolve_route(selected_index)
		"charge":
			return _resolve_charge(selected_index)
		"binary":
			return _resolve_binary(selected_index)
		_:
			return _resolve_sequence(selected_index)

func _resolve_sequence(selected_index: int) -> Dictionary:
	if selected_index == sequence[progress]:
		progress += 1
		_highlight_rune(selected_index, true)
		if progress >= sequence.size():
			return _solve()
		_set_status("%s // RUNE %d / %d" % [str(profile.get("name", "PUZZLE")), progress, sequence.size()])
		return {"accepted": true, "reason": "correct", "progress": progress}
	return _reset("WRONG ROUTE // READ THE ENVIRONMENT")

func _resolve_route(selected_index: int) -> Dictionary:
	if selected_index == int(profile.get("correctIndex", 0)):
		_highlight_rune(selected_index, true)
		return _solve()
	return _reset("FALSE ROUTE // FOLLOW THE ENVIRONMENT")

func _resolve_charge(selected_index: int) -> Dictionary:
	if selected_index == int(profile.get("anchorIndex", 0)):
		progress += 1
		_highlight_rune(selected_index, true)
		if progress >= charge_hits_required:
			return _solve()
		_set_status("%s // CHARGE %d / %d" % [str(profile.get("name", "PUZZLE")), progress, charge_hits_required])
		return {"accepted": true, "reason": "charging", "progress": progress}
	return _reset("CHARGE LOST // HIT THE POWER CORE")

func _resolve_binary(selected_index: int) -> Dictionary:
	if not required_indices.has(selected_index):
		return _reset("FALSE SWITCH // READ THE RIGGING")
	if sequence.has(selected_index):
		return {"accepted": true, "reason": "already_active", "progress": progress}
	sequence.append(selected_index)
	progress = sequence.size()
	_highlight_rune(selected_index, true)
	if progress >= required_indices.size():
		return _solve()
	_set_status("%s // LOCK %d / %d" % [str(profile.get("name", "PUZZLE")), progress, required_indices.size()])
	return {"accepted": true, "reason": "switch_active", "progress": progress}

func _solve() -> Dictionary:
	complete = true
	_set_status("%s // ROUTE OPEN" % str(profile.get("name", "PUZZLE")))
	solved.emit(level_id, checkpoint_index)
	return {"accepted": true, "reason": "solved", "puzzle": str(profile.get("name", "PUZZLE")), "mode": puzzle_mode}

func _reset(message: String) -> Dictionary:
	progress = 0
	if puzzle_mode == "binary":
		sequence.clear()
	for index in rune_materials.size():
		_highlight_rune(index, false)
	_set_status(message)
	return {"accepted": true, "reason": "wrong", "progress": 0}

func _build_gate() -> void:
	status_label = Label3D.new()
	status_label.name = "PuzzlePrompt"
	status_label.text = str(profile.get("prompt", "FIND THE ROUTE"))
	status_label.font_size = 34
	status_label.outline_size = 7
	status_label.modulate = Color("F5F0E9")
	status_label.position = Vector3(-2.5, 3.25, 0)
	add_child(status_label)
	var colors := [Color("C7973A"), Color("8D2634"), Color("4A877A")]
	for index in range(3):
		var rune_body := StaticBody3D.new()
		rune_body.name = "PuzzleRune_%d" % index
		rune_body.collision_layer = 8
		rune_body.collision_mask = 0
		rune_body.position = Vector3((float(index) - 1.0) * 1.5, 1.16, 0)
		rune_body.set_meta("nightfall_damage_target", self)
		add_child(rune_body)
		rune_positions.append(rune_body.global_position)
		var collider := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 0.44
		shape.height = 1.9
		collider.shape = shape
		rune_body.add_child(collider)
		var rune_mesh := MeshInstance3D.new()
		var mesh: PrimitiveMesh = PrismMesh.new()
		if puzzle_mode == "charge" and index == int(profile.get("anchorIndex", 0)):
			mesh = TorusMesh.new()
		elif puzzle_mode == "route":
			var route_mesh := CylinderMesh.new()
			route_mesh.top_radius = 0.44
			route_mesh.bottom_radius = 0.62
			route_mesh.height = 1.82
			mesh = route_mesh
		else:
			var prism := mesh as PrismMesh
			prism.left_to_right = 0.68
			prism.size = Vector3(0.78, 1.82, 0.78)
		var material := StandardMaterial3D.new()
		material.albedo_color = colors[index].darkened(0.25)
		material.metallic = 0.72
		material.roughness = 0.24
		material.emission_enabled = true
		material.emission = colors[index]
		material.emission_energy_multiplier = 1.45
		mesh.material = material
		rune_mesh.mesh = mesh
		rune_body.add_child(rune_mesh)
		rune_materials.append(material)

func _nearest_rune_index(impact_position: Vector3) -> int:
	var nearest_index := 0
	var nearest_distance := INF
	for index in rune_positions.size():
		var distance := rune_positions[index].distance_squared_to(impact_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index

func _highlight_rune(index: int, selected: bool) -> void:
	if index < 0 or index >= rune_materials.size():
		return
	rune_materials[index].emission_energy_multiplier = 5.4 if selected else 1.45

func _set_status(value: String) -> void:
	if status_label:
		status_label.text = value
