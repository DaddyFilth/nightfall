extends SceneTree

const NightfallInput = preload("res://scripts/gameplay/nightfall_input.gd")
const RemapCapture = preload("res://scripts/gameplay/gamepad_remap_capture.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	NightfallInput.ensure_default_actions()
	var capture := RemapCapture.new()
	root.add_child(capture)
	_assert(capture.begin_capture("nightfall_fire"), "begin_fire")
	var button_event := InputEventJoypadButton.new()
	button_event.device = 0
	button_event.button_index = JOY_BUTTON_X
	button_event.pressed = true
	capture._unhandled_input(button_event)
	_assert(NightfallInput.primary_gamepad_button("nightfall_fire") == JOY_BUTTON_X, "capture_fire_x")
	NightfallInput.load_gamepad_bindings()
	_assert(NightfallInput.primary_gamepad_button("nightfall_fire") == JOY_BUTTON_X, "persist_fire_x")
	_assert(capture.begin_capture("nightfall_ability"), "begin_ability")
	capture._unhandled_input(button_event)
	_assert(capture.pending_conflict_action == "nightfall_fire", "detect_conflict")
	_assert(capture.confirm_conflict_replacement(), "confirm_conflict")
	_assert(NightfallInput.primary_gamepad_button("nightfall_ability") == JOY_BUTTON_X, "ability_receives_x")
	_assert(NightfallInput.primary_gamepad_button("nightfall_fire") != JOY_BUTTON_X, "fire_released_x")
	_assert(not capture.begin_capture("nightfall_move_left"), "reject_axis_action")
	print("GAMEPAD_REMAP_PASS action=fire,ability button=x conflict=replaced persistence=local")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("GAMEPAD_REMAP_FAIL " + label)
		quit(1)
