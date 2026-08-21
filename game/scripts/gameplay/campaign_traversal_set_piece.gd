class_name CampaignTraversalSetPiece
extends Node3D

var profile: Dictionary = {}
var accent := Color("C7973A")
var checkpoint_progress := 0
var phase := 0.0
var traversal_core: MeshInstance3D
var traversal_light: OmniLight3D
var traversal_label: Label3D

func configure(next_profile: Dictionary, next_accent: Color) -> void:
	profile = next_profile.duplicate(true)
	accent = next_accent

func _ready() -> void:
	name = "TraversalSetPiece_%s" % str(profile.get("mode", "route"))
	_build_route()

func activate_checkpoint(index: int) -> void:
	checkpoint_progress = max(checkpoint_progress, index)
	if traversal_label:
		traversal_label.text = "%s // ROUTE SECURED %02d" % [str(profile.get("name", "TRAVERSAL")), checkpoint_progress]
	if traversal_light:
		traversal_light.light_energy = 6.0

func _process(delta: float) -> void:
	phase += delta
	if traversal_core:
		traversal_core.rotation.y += delta * 0.8
		traversal_core.position.y = 1.45 + sin(phase * 1.8) * 0.22 + min(checkpoint_progress, 3) * 0.08
	if traversal_light:
		var target_energy := 2.2 + float(checkpoint_progress) * 0.55
		traversal_light.light_energy = move_toward(traversal_light.light_energy, target_energy, delta * 5.0)

func _build_route() -> void:
	var deck := MeshInstance3D.new()
	deck.name = "TraversalDeck"
	var deck_mesh := BoxMesh.new()
	deck_mesh.size = Vector3(4.6, 0.25, 1.45)
	deck.mesh = deck_mesh
	deck.material_override = _material(accent.darkened(0.4), 0.65)
	add_child(deck)
	var body := StaticBody3D.new()
	body.name = "TraversalDeckCollision"
	body.collision_layer = 1
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.6, 0.25, 1.45)
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	traversal_core = MeshInstance3D.new()
	traversal_core.name = "TraversalCore_%s" % str(profile.get("mode", "route"))
	var core_mesh: PrimitiveMesh = TorusMesh.new()
	if str(profile.get("mode", "")) in ["chain", "boarding", "leviathan"]:
		var prism := PrismMesh.new()
		prism.left_to_right = 0.72
		prism.size = Vector3(1.2, 2.6, 1.2)
		core_mesh = prism
	traversal_core.mesh = core_mesh
	traversal_core.position.y = 1.45
	traversal_core.material_override = _material(accent, 3.6)
	add_child(traversal_core)
	traversal_light = OmniLight3D.new()
	traversal_light.name = "TraversalLight"
	traversal_light.light_color = accent
	traversal_light.light_energy = 2.2
	traversal_light.omni_range = 8.0
	traversal_light.position = Vector3(0, 2.5, 0)
	add_child(traversal_light)
	traversal_label = Label3D.new()
	traversal_label.name = "TraversalLabel"
	traversal_label.text = "%s // AWAIT CHECKPOINT" % str(profile.get("name", "TRAVERSAL"))
	traversal_label.font_size = 38
	traversal_label.outline_size = 8
	traversal_label.modulate = Color("F5F0E9")
	traversal_label.position = Vector3(-2.2, 2.9, 0)
	add_child(traversal_label)

func _material(color: Color, emission: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.72
	material.roughness = 0.25
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material
