extends SceneTree

const Conductor = preload("res://scripts/gameplay/observatory_conductor.gd")
const Projectile = preload("res://scripts/gameplay/nightfall_projectile.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var arena := Node3D.new()
	root.add_child(arena)
	var conductor := Conductor.new()
	conductor.configure_branch("static_trail")
	arena.add_child(conductor)
	await physics_frame
	var projectile := Projectile.new()
	arena.add_child(projectile)
	projectile.fire(Vector3(0, 2.5, 8.0), Vector3(0, 0, -1))
	var result: Dictionary = projectile.resolve_segment(18.0)
	_assert(result["kind"] == "target", "projectile_hits_conductor")
	_assert(conductor.vitality == 335, "damage_applied")
	conductor.apply_damage(110)
	_assert(conductor.phase == 2, "phase_two")
	_assert(conductor.telegraph_label.text.contains("LATTICE SCISSION"), "telegraph_updated")
	print("CONDUCTOR_PROJECTILE_PASS hurtbox=live damage=25 telegraph=phase_two")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("CONDUCTOR_PROJECTILE_FAIL " + label)
		quit(1)
