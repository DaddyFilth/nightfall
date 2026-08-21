extends SceneTree

const ArenaScene = preload("res://scenes/arena_showcase.tscn")
const Player = preload("res://scripts/gameplay/nightfall_player.gd")
const Projectile = preload("res://scripts/gameplay/nightfall_projectile.gd")
const Hollowed = preload("res://scripts/presentation/hollowed_actor.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var arena := ArenaScene.instantiate()
	root.add_child(arena)
	var player := Player.new()
	player.position = Vector3(7.2, 0.0, 0.0)
	arena.add_child(player)
	await physics_frame
	player.move_for_test(Vector3(1, 0, 0), 1.0)
	_assert(player.global_position.x < 8.05, "wall_collision")

	var target := Hollowed.new()
	target.position = Vector3(0, 0, 4.0)
	arena.add_child(target)
	await physics_frame
	var projectile := Projectile.new()
	arena.add_child(projectile)
	projectile.fire(Vector3(0, 1.0, 0.0), Vector3(0, 0, 1))
	var target_hit: Dictionary = projectile.resolve_segment(8.0)
	_assert(target_hit["kind"] == "target", "projectile_target_kind")
	_assert(target.health == 75, "projectile_damage")
	_assert(target.animation_state_name() == "hit", "projectile_hit_state")

	var wall_projectile := Projectile.new()
	arena.add_child(wall_projectile)
	wall_projectile.fire(Vector3(7.3, 1.0, -13.0), Vector3(1, 0, 0))
	var solid_hit: Dictionary = wall_projectile.resolve_segment(3.0)
	_assert(solid_hit["kind"] == "solid", "projectile_solid_kind")
	print("COLLISION_PROJECTILE_PASS player=constrained target_damage=25 solid_blocked=true")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("COLLISION_PROJECTILE_FAIL " + label)
		quit(1)
