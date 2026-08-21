extends SceneTree

const Conductor = preload("res://scripts/gameplay/observatory_conductor.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var civic := Conductor.new()
	civic.configure_branch("last_platform")
	root.add_child(civic)
	await process_frame
	_assert(civic.shell.name == "DrownedAdmiralShell" and civic.shell.get_node_or_null("AdmiralTricornCrown") != null and civic.shell.get_node_or_null("AdmiralAstrolabe") != null, "drowned_admiral_visual")
	_assert(civic.current_mechanic() == "BEACON SANCTUARY", "civic_phase_one")
	civic.apply_damage(130)
	_assert(civic.phase == 2 and civic.current_mechanic() == "EVACUATION MIRRORS", "civic_phase_two")
	var civic_result: Dictionary = civic.apply_damage(230)
	_assert(civic_result["reward"]["title"] == "CIVIC WAYFINDER" and not civic_result["reward"]["advantage"], "civic_reward")

	var cipher := Conductor.new()
	cipher.configure_branch("static_trail")
	root.add_child(cipher)
	await process_frame
	cipher.apply_damage(260)
	_assert(cipher.phase == 3 and cipher.current_mechanic() == "CIPHER OVERLOAD", "cipher_phase_three")
	var cipher_result: Dictionary = cipher.apply_damage(100)
	_assert(cipher_result["reward"]["title"] == "RELAY BREAKER" and not cipher_result["reward"]["advantage"], "cipher_reward")
	print("OBSERVATORY_CONDUCTOR_PASS branches=civic,cipher visual=drowned_admiral rewards=cosmetic_only")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("OBSERVATORY_CONDUCTOR_FAIL " + label)
		quit(1)
