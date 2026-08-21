extends SceneTree

const ObservatoryArena = preload("res://scripts/presentation/observatory_arena.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var civic := ObservatoryArena.new()
	civic.configure_branch("last_platform")
	root.add_child(civic)
	await process_frame
	var civic_entry := civic.get_node_or_null("CivicServiceEntry")
	_assert(civic_entry != null, "civic_entry")
	_assert(civic_entry.find_child("*Collision", true, false) != null, "civic_collision")
	_assert(civic.get_node_or_null("ConductorBossHUD/ConductorVitalityBar") != null, "boss_vitality_hud")
	_assert(civic.get_node_or_null("ConductorBossHUD/ConductorVitalityLabel") != null, "boss_vitality_label")
	civic.queue_free()
	await process_frame

	var lattice := ObservatoryArena.new()
	lattice.configure_branch("static_trail")
	root.add_child(lattice)
	await process_frame
	_assert(lattice.get_node_or_null("LatticeGapEntry") != null, "lattice_entry")
	_assert(lattice.get_node_or_null("LatticeGapEntry/CipherWindow") != null, "lattice_window")
	_assert(lattice.get_node_or_null("CivicServiceEntry") == null, "lattice_excludes_civic")
	print("OBSERVATORY_ARENA_PASS branches=civic_service,lattice_gap geometry=distinct boss_hud=visible")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("OBSERVATORY_ARENA_FAIL " + label)
		quit(1)
