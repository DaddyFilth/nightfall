extends SceneTree

const Rules = preload("res://scripts/rules/local_mode_simulator.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var tdm = Rules.new()
	_assert(tdm.configure("team_deathmatch", 2), "tdm_config")
	_assert(tdm.register_player(1, "crimson"), "tdm_crimson")
	_assert(tdm.register_player(2, "violet"), "tdm_violet")
	_assert(tdm.record_elimination(1, 2)["scored"], "tdm_first_score")
	_assert(tdm.record_elimination(1, 2)["complete"], "tdm_score_limit")
	_assert(tdm.snapshot()["teams"]["crimson"] == 2, "tdm_team_score")

	var ctf = Rules.new()
	_assert(ctf.configure("capture_the_flag", 2), "ctf_config")
	_assert(ctf.register_player(11, "crimson"), "ctf_crimson")
	_assert(ctf.register_player(12, "violet"), "ctf_violet")
	_assert(ctf.pickup_relic(11, "violet"), "ctf_pickup_enemy_relic")
	_assert(not ctf.capture_relic(11, "violet"), "ctf_reject_enemy_sanctuary")
	_assert(ctf.capture_relic(11, "crimson"), "ctf_capture_home_sanctuary")
	_assert(ctf.snapshot()["teams"]["crimson"] == 1, "ctf_score")
	_assert(not ctf.pickup_relic(11, "crimson"), "ctf_reject_home_relic")
	print("LOCAL_MODES_PASS tdm=team_deathmatch ctf=capture_the_flag")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("LOCAL_MODES_FAIL " + label)
		quit(1)
