extends SceneTree

const NightfallInput = preload("res://scripts/gameplay/nightfall_input.gd")
const Player = preload("res://scripts/gameplay/nightfall_player.gd")
const TouchOverlay = preload("res://scripts/gameplay/nightfall_touch_overlay.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://nightfall/fps-settings.v1.cfg"))
	NightfallInput.ensure_default_actions()
	for action in NightfallInput.ACTIONS:
		_assert(InputMap.has_action(action), "action_" + action)
	_assert(InputMap.action_get_events("nightfall_move_left").size() >= 2, "keyboard_gamepad_move")
	_assert(InputMap.action_get_events("nightfall_fire").size() >= 2, "keyboard_gamepad_fire")
	var player := Player.new()
	root.add_child(player)
	var overlay := TouchOverlay.new()
	root.add_child(overlay)
	player.set_touch_overlay(overlay)
	await process_frame
	player.set_aim_sensitivity(1.6)
	player.set_aim_invert_y(false)
	player.rotation.y = 0.0
	player.camera_pitch = 0.0
	player.apply_look_delta(Vector2(100, 20))
	_assert(is_equal_approx(player.rotation.y, -0.512), "aim_sensitivity_scaled_yaw")
	_assert(is_equal_approx(player.camera_pitch, -0.1024), "aim_standard_vertical")
	player.set_aim_invert_y(true)
	player.rotation.y = 0.0
	player.camera_pitch = 0.0
	player.apply_look_delta(Vector2(0, 20))
	_assert(is_equal_approx(player.camera_pitch, 0.1024), "aim_invert_y")
	player.set_aim_sensitivity(9.0)
	_assert(is_equal_approx(player.aim_sensitivity, Player.MAX_AIM_SENSITIVITY), "aim_sensitivity_upper_clamp")
	player.set_aim_sensitivity(0.1)
	_assert(is_equal_approx(player.aim_sensitivity, Player.MIN_AIM_SENSITIVITY), "aim_sensitivity_lower_clamp")
	player.set_aim_sensitivity(1.35)
	var persisted_player := Player.new()
	root.add_child(persisted_player)
	await process_frame
	_assert(is_equal_approx(persisted_player.aim_sensitivity, 1.35) and persisted_player.aim_invert_y, "aim_preferences_persisted")
	var action_events: Array[String] = []
	overlay.fire_requested.connect(func() -> void: action_events.append("fire"))
	overlay.ability_requested.connect(func() -> void: action_events.append("ability"))
	overlay.dodge_requested.connect(func() -> void: action_events.append("dodge"))
	var move_press := InputEventScreenTouch.new()
	move_press.index = 4
	move_press.pressed = true
	move_press.position = overlay.joystick_center() + Vector2(overlay.joystick_radius() * 0.72, 0)
	overlay._input(move_press)
	_assert(overlay.virtual_move.x > 0.5, "touch_move_press")
	var look_press := InputEventScreenTouch.new()
	look_press.index = 8
	look_press.pressed = true
	look_press.position = Vector2(overlay.get_viewport_rect().size.x * 0.58, overlay.get_viewport_rect().size.y * 0.25)
	overlay._input(look_press)
	var look_drag := InputEventScreenDrag.new()
	look_drag.index = 8
	look_drag.position = look_press.position + Vector2(68, -24)
	overlay._input(look_drag)
	var look_delta := overlay.consume_look_delta()
	_assert(look_delta.x > 60.0 and look_delta.y < -20.0, "touch_look_drag")
	var fire_press := InputEventScreenTouch.new()
	fire_press.index = 5
	fire_press.pressed = true
	fire_press.position = overlay.fire_center()
	overlay._input(fire_press)
	var ability_press := InputEventScreenTouch.new()
	ability_press.index = 6
	ability_press.pressed = true
	ability_press.position = overlay.ability_center()
	overlay._input(ability_press)
	var dodge_press := InputEventScreenTouch.new()
	dodge_press.index = 7
	dodge_press.pressed = true
	dodge_press.position = overlay.dodge_center()
	overlay._input(dodge_press)
	_assert(action_events.count("fire") == 1 and action_events.count("ability") == 1 and action_events.count("dodge") == 1, "touch_action_signals events=%s" % [action_events])
	_assert(overlay._is_action_pressed("fire") and overlay._is_action_pressed("ability") and overlay._is_action_pressed("dodge"), "touch_press_feedback")
	_assert(overlay.action_feedback_strength("fire") > 0.0 and overlay.action_feedback_strength("ability") > 0.0 and overlay.action_feedback_strength("dodge") > 0.0, "touch_press_animation_started")
	overlay._process(0.25)
	_assert(overlay.action_feedback_strength("fire") == 0.0 and overlay.action_feedback_strength("ability") == 0.0 and overlay.action_feedback_strength("dodge") == 0.0, "touch_press_animation_cleared")
	await physics_frame
	var before := player.global_position
	player._physics_process(0.25)
	_assert(player.global_position.x > before.x, "touch_move_consumed")
	var move_release := InputEventScreenTouch.new()
	move_release.index = 4
	move_release.pressed = false
	move_release.position = move_press.position
	overlay._input(move_release)
	_assert(overlay.virtual_move == Vector2.ZERO, "touch_move_release")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://nightfall/fps-settings.v1.cfg"))
	print("INPUT_HARNESS_PASS touch=move,fire,ability,dodge aim=sensitivity,invert,persisted gamepad=mapped keyboard=mapped")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("INPUT_HARNESS_FAIL " + label)
		quit(1)
