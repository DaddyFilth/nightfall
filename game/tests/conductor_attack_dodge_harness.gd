extends SceneTree

const Conductor = preload("res://scripts/gameplay/observatory_conductor.gd")
const Player = preload("res://scripts/gameplay/nightfall_player.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var arena := Node3D.new()
	root.add_child(arena)
	var player := Player.new()
	player.position = Vector3(0, 0, -2.4)
	arena.add_child(player)
	var conductor := Conductor.new()
	conductor.configure_branch("last_platform")
	conductor.track_player(player)
	arena.add_child(conductor)
	await physics_frame
	conductor._physics_process(1.0)
	_assert(conductor.shell.position.x == 0.0, "movement_tracks_player")
	var started := conductor.trigger_attack()
	_assert(started.is_empty() and conductor.is_winding_up, "attack_begins_windup")
	_assert(conductor.telegraph_label.text.contains("INCOMING"), "windup_visuals_announced")
	conductor._physics_process(0.12)
	_assert(conductor.telegraph_ring.scale.x > 1.0 and conductor.shell_material.emission_energy_multiplier > 3.0, "windup_visuals_amplified")
	conductor._physics_process(0.23)
	_assert(player.vitality == 100, "damage_waits_for_windup")
	conductor._physics_process(0.4)
	_assert(player.vitality == 84, "damage_applied_after_windup")
	_assert(player.knockback_velocity.length() > 0.1, "knockback_applied")
	_assert(conductor.telegraph_label.text.contains("DODGE WINDOW READY"), "telegraph_resets_after_attack")
	_assert(player.begin_dodge(), "dodge_begins")
	player.knockback_velocity = Vector3.ZERO
	conductor.trigger_attack()
	conductor._physics_process(0.8)
	_assert(player.vitality == 84 and player.knockback_velocity.length() < 0.01, "dodge_avoids_damage_and_knockback")
	print("CONDUCTOR_ATTACK_DODGE_PASS hitbox=live windup=telegraphed knockback=applied dodge=invulnerable")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("CONDUCTOR_ATTACK_DODGE_FAIL " + label)
		quit(1)
