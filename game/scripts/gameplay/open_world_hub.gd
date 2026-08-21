extends "res://scripts/presentation/procedural_station_arena.gd"

const OpenWorldDistricts = preload("res://scripts/gameplay/open_world_districts.gd")
const OpenWorldProgress = preload("res://scripts/gameplay/open_world_progress.gd")

var exploration_player: NightfallPlayer
var district_label: Label
var objective_label: Label
var discovered_districts := PackedStringArray()
var active_district_id := "brasswake_dockyards"
var open_world_time := 0.0
var discovery_beacons: Array[MeshInstance3D] = []

func _ready() -> void:
	super._ready()
	name = "BrasswakeOpenWorldHub"
	exploration_player = get_node_or_null("NightfallPlayer") as NightfallPlayer
	discovered_districts = OpenWorldProgress.visited_districts()
	_build_open_world_districts()
	_build_exploration_hud()
	_enter_district("brasswake_dockyards")

func _process(delta: float) -> void:
	super._process(delta)
	open_world_time += delta
	for index in discovery_beacons.size():
		var beacon := discovery_beacons[index]
		if is_instance_valid(beacon):
			beacon.position.y = 1.2 + sin(open_world_time * 1.7 + float(index)) * 0.15
			beacon.rotation_degrees.y += delta * 38.0

func _build_open_world_districts() -> void:
	for index in OpenWorldDistricts.count():
		var district := OpenWorldDistricts.district(index)
		_build_district_landmark(district, index)

func _build_district_landmark(district: Dictionary, index: int) -> void:
	var position := district.get("position", Vector3.ZERO) as Vector3
	var accent := district.get("accent", Color("C7973A")) as Color
	var district_id := str(district.get("id", "brasswake_dockyards"))
	var district_title := str(district.get("title", "BRASSWAKE DOCKYARDS"))
	_block("DistrictDeck_%s" % district_id, Vector3(6.2, 0.22, 5.0), position + Vector3(0, 0.0, -0.5), Color("182126"), 0.05, true)
	_block("DistrictArch_%s" % district_id, Vector3(0.42, 3.4, 0.42), position + Vector3(-2.5, 1.6, -2.2), accent, 0.16, true)
	_block("DistrictArch_%s_Right" % district_id, Vector3(0.42, 3.4, 0.42), position + Vector3(2.5, 1.6, -2.2), accent, 0.16, true)
	_block("DistrictLintel_%s" % district_id, Vector3(5.35, 0.38, 0.45), position + Vector3(0, 3.1, -2.2), accent, 0.12, true)
	var title := Label3D.new()
	title.name = "DistrictSign_%s" % district_id
	title.text = district_title
	title.position = position + Vector3(0, 3.55, -2.1)
	title.font_size = 48
	title.outline_size = 8
	title.modulate = accent
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(title)
	var beacon := MeshInstance3D.new()
	beacon.name = "WorldDiscovery_%s" % district_id
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.12
	beacon_mesh.bottom_radius = 0.30
	beacon_mesh.height = 1.3
	beacon.mesh = beacon_mesh
	beacon.material_override = _material(accent, 0.86, 1.25, 0.20)
	beacon.position = position + Vector3(0, 1.2, 0.8)
	add_child(beacon)
	discovery_beacons.append(beacon)
	var trigger := Area3D.new()
	trigger.name = "DistrictDiscovery_%s" % district_id
	trigger.position = position + Vector3(0, 1.0, 0.8)
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.45
	shape.shape = sphere
	trigger.add_child(shape)
	trigger.body_entered.connect(_on_district_body_entered.bind(district_id))
	add_child(trigger)
	for prop_index in range(3):
		var offset := Vector3(-1.8 + float(prop_index) * 1.8, 0.72, 1.6)
		_block("DistrictCargo_%s_%02d" % [district_id, prop_index], Vector3(0.95, 1.4, 0.95), position + offset, accent.darkened(0.38), 0.03, true)

func _build_exploration_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "OpenWorldExplorationHUD"
	add_child(layer)
	var frame := ColorRect.new()
	frame.name = "OpenWorldObjectiveFrame"
	frame.position = Vector2(22, 22)
	frame.size = Vector2(492, 74)
	frame.color = Color("100C0AE8")
	layer.add_child(frame)
	district_label = Label.new()
	district_label.name = "OpenWorldDistrictLabel"
	district_label.position = Vector2(14, 10)
	district_label.size = Vector2(464, 20)
	district_label.add_theme_font_size_override("font_size", 15)
	district_label.add_theme_color_override("font_color", Color("EDE1C4"))
	frame.add_child(district_label)
	objective_label = Label.new()
	objective_label.name = "OpenWorldObjectiveLabel"
	objective_label.position = Vector2(14, 36)
	objective_label.size = Vector2(464, 26)
	objective_label.add_theme_font_size_override("font_size", 10)
	objective_label.add_theme_color_override("font_color", Color("A9CAC7"))
	frame.add_child(objective_label)
	var return_button := Button.new()
	return_button.name = "ReturnToDrownedChartButton"
	return_button.text = "RETURN TO DROWNED CHART"
	return_button.position = Vector2(1004, 34)
	return_button.size = Vector2(240, 34)
	return_button.add_theme_font_size_override("font_size", 10)
	return_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/campaign_hub.tscn"))
	layer.add_child(return_button)

func _on_district_body_entered(body: Node3D, district_id: String) -> void:
	if body != exploration_player:
		return
	_enter_district(district_id)

func _enter_district(district_id: String) -> void:
	active_district_id = district_id
	discovered_districts = OpenWorldProgress.record_district_visit(district_id)
	var district := OpenWorldDistricts.district_for_id(district_id)
	if district_label:
		district_label.text = "%s // OPEN WATERS" % str(district.get("title", "BRASSWAKE DOCKYARDS"))
	if objective_label:
		objective_label.text = "%s\nEXPLORED %02d / %02d DISTRICTS // OPTIONAL DISCOVERIES NEVER UNLOCK THE NEXT STORY MISSION" % [str(district.get("subtitle", "")), discovered_districts.size(), OpenWorldDistricts.count()]
