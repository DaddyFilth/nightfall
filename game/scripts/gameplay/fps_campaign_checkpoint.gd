class_name FpsCampaignCheckpoint
extends Node3D

signal activated(level_id: int, checkpoint_index: int)

var level_id := 1
var checkpoint_index := 1
var checkpoint_label := ""
var active := true
var phase := 0.0
var beacon: MeshInstance3D
var beacon_light: OmniLight3D

func configure(next_level_id: int, next_checkpoint_index: int, next_label: String) -> void:
	level_id = next_level_id
	checkpoint_index = next_checkpoint_index
	checkpoint_label = next_label

func _ready() -> void:
	name = "CampaignCheckpoint_%02d_%02d" % [level_id, checkpoint_index]
	_build_visuals()
	_build_trigger()

func _process(delta: float) -> void:
	if not active:
		return
	phase += delta
	if is_instance_valid(beacon):
		beacon.rotation_degrees.y += delta * 54.0
		beacon.position.y = 1.18 + sin(phase * 2.4) * 0.18
		beacon.scale = Vector3.ONE * (1.0 + sin(phase * 3.4) * 0.08)
	if is_instance_valid(beacon_light):
		beacon_light.light_energy = 3.2 + sin(phase * 3.4) * 0.75

func _build_visuals() -> void:
	beacon = MeshInstance3D.new()
	beacon.name = "CheckpointBeacon"
	var mesh := PrismMesh.new()
	mesh.left_to_right = 0.68
	mesh.size = Vector3(0.82, 2.25, 0.82)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("B68A39")
	material.metallic = 0.8
	material.roughness = 0.22
	material.emission_enabled = true
	material.emission = Color("E7CB63")
	material.emission_energy_multiplier = 3.4
	mesh.material = material
	beacon.mesh = mesh
	beacon.position.y = 1.18
	add_child(beacon)
	beacon_light = OmniLight3D.new()
	beacon_light.name = "CheckpointLight"
	beacon_light.light_color = Color("E7CB63")
	beacon_light.light_energy = 3.2
	beacon_light.omni_range = 7.0
	beacon_light.position.y = 1.15
	add_child(beacon_light)

func _build_trigger() -> void:
	var area := Area3D.new()
	area.name = "CheckpointTrigger"
	area.collision_layer = 0
	area.collision_mask = 2
	var collider := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.45
	shape.height = 2.6
	collider.shape = shape
	collider.position.y = 1.3
	area.add_child(collider)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

func _on_body_entered(body: Node3D) -> void:
	if not active or not body is NightfallPlayer:
		return
	active = false
	activated.emit(level_id, checkpoint_index)
	queue_free()
