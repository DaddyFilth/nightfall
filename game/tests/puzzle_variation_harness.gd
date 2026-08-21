extends SceneTree

const CampaignPuzzleGate = preload("res://scripts/gameplay/campaign_puzzle_gate.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_route()
	await _assert_charge()
	await _assert_binary()
	print("PUZZLE_VARIATION_PASS route=choice charge=core binary=switches")
	quit(0)

func _gate(profile: Dictionary) -> CampaignPuzzleGate:
	var gate := CampaignPuzzleGate.new()
	gate.configure(1, 1, profile)
	root.add_child(gate)
	return gate

func _assert_route() -> void:
	var gate := _gate({"name": "ROUTE", "mode": "route", "correctIndex": 2})
	await process_frame
	gate.take_projectile_hit(25, gate.rune_positions[0])
	if gate.complete:
		_fail("route_wrong_accept")
		return
	gate.take_projectile_hit(25, gate.rune_positions[2])
	if not gate.complete:
		_fail("route_correct_open")
	gate.queue_free()

func _assert_charge() -> void:
	var gate := _gate({"name": "CHARGE", "mode": "charge", "anchorIndex": 1, "hitsRequired": 3})
	await process_frame
	for _index in 3:
		gate.take_projectile_hit(25, gate.rune_positions[1])
	if not gate.complete:
		_fail("charge_open")
	gate.queue_free()

func _assert_binary() -> void:
	var gate := _gate({"name": "BINARY", "mode": "binary", "requiredSet": [0, 2]})
	await process_frame
	gate.take_projectile_hit(25, gate.rune_positions[2])
	gate.take_projectile_hit(25, gate.rune_positions[0])
	if not gate.complete:
		_fail("binary_open")
	gate.queue_free()

func _fail(label: String) -> void:
	printerr("PUZZLE_VARIATION_FAIL " + label)
	quit(1)
