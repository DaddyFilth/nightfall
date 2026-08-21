extends SceneTree

const FpsClassRoster = preload("res://scripts/gameplay/fps_class_roster.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert(FpsClassRoster.CLASS_IDS.size() == 6, "six_classes")
	var weapon_names := {}
	for class_id in FpsClassRoster.CLASS_IDS:
		var profile := FpsClassRoster.profile(class_id)
		_assert(not str(profile.get("label", "")).is_empty(), "label_%s" % class_id)
		_assert(not str(profile.get("primary_weapon", "")).is_empty(), "primary_%s" % class_id)
		_assert(not str(profile.get("ability_name", "")).is_empty(), "ability_%s" % class_id)
		_assert(float(profile.get("move_speed", 0.0)) > 0.0, "speed_%s" % class_id)
		_assert(int(profile.get("primary_damage", 0)) > 0, "damage_%s" % class_id)
		weapon_names[str(profile.get("primary_weapon", ""))] = true
	_assert(weapon_names.size() == 6, "unique_primary_weapons")
	_assert(FpsClassRoster.normalized_id("invalid") == FpsClassRoster.DEFAULT_CLASS_ID, "safe_fallback")
	print("FPS_CLASS_ROSTER_PASS classes=6 first_person_loadouts=unique")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("FPS_CLASS_ROSTER_FAIL " + label)
		quit(1)
