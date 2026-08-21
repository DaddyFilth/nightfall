extends SceneTree

const CampaignPuzzleGate = preload("res://scripts/gameplay/campaign_puzzle_gate.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var gate := CampaignPuzzleGate.new()
	gate.configure(2, 1, {"name": "TEST COMPASS", "prompt": "TEST", "sequence": [2, 0, 1]})
	root.add_child(gate)
	await process_frame
	var wrong: Dictionary = gate.take_projectile_hit(25, gate.rune_positions[0])
	if not (wrong.get("reason", "") == "wrong" and gate.progress == 0):
		_fail("wrong_route_resets")
		return
	for rune_index in [2, 0, 1]:
		gate.take_projectile_hit(25, gate.rune_positions[rune_index])
	if not (gate.complete and gate.progress == 3):
		_fail("correct_route_opens")
		return
	if not (gate.get_node_or_null("PuzzleRune_0") != null and gate.get_node_or_null("PuzzlePrompt") != null):
		_fail("world_objects_present")
		return
	print("PUZZLE_GATE_PASS route=ordered world_objects=interactive checkpoint=unlocked")
	quit(0)

func _fail(label: String) -> void:
	printerr("PUZZLE_GATE_FAIL " + label)
	quit(1)
