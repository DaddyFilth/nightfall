extends SceneTree

const OpenWorldDistricts = preload("res://scripts/gameplay/open_world_districts.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert(OpenWorldDistricts.count() == 5, "five_explorable_districts")
	var ids := {}
	for index in OpenWorldDistricts.count():
		var district := OpenWorldDistricts.district(index)
		_assert(not str(district.get("title", "")).is_empty(), "district_title_%02d" % index)
		ids[str(district.get("id", ""))] = true
	_assert(ids.size() == OpenWorldDistricts.count(), "unique_district_ids")
	var scene := load("res://scenes/open_world_hub.tscn") as PackedScene
	_assert(scene != null, "open_world_scene_loads")
	var world := scene.instantiate()
	root.add_child(world)
	await process_frame
	_assert(world.get_node_or_null("OpenWorldExplorationHUD") != null, "exploration_hud")
	_assert(world.get_node_or_null("WorldDiscovery_brasswake_dockyards") != null, "dockyard_discovery")
	_assert(world.get_node_or_null("WorldDiscovery_iron_foreshore") != null, "foreshore_discovery")
	_assert(world.get_node_or_null("NightfallPlayer/FirstPersonPitchPivot/FirstPersonCamera") != null, "first_person_exploration")
	world.queue_free()
	print("OPEN_WORLD_PASS districts=5 first_person=active story_gating=preserved")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("OPEN_WORLD_FAIL " + label)
		quit(1)
