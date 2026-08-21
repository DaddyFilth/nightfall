class_name NightfallInput
extends RefCounted

const ACTIONS := ["nightfall_move_left", "nightfall_move_right", "nightfall_move_up", "nightfall_move_down", "nightfall_aim_left", "nightfall_aim_right", "nightfall_aim_up", "nightfall_aim_down", "nightfall_fire", "nightfall_ability", "nightfall_dodge"]
const REMAPPABLE_ACTIONS := ["nightfall_fire", "nightfall_ability"]
const GAMEPAD_BINDING_PATH := "user://nightfall/gamepad-bindings.v1.cfg"

static func ensure_default_actions() -> void:
	_register_key("nightfall_move_left", KEY_A)
	_register_key("nightfall_move_right", KEY_D)
	_register_key("nightfall_move_up", KEY_W)
	_register_key("nightfall_move_down", KEY_S)
	_register_key("nightfall_fire", KEY_SPACE)
	_register_key("nightfall_ability", KEY_E)
	_register_key("nightfall_dodge", KEY_SHIFT)
	_register_joy_axis("nightfall_move_left", JOY_AXIS_LEFT_X, -1.0)
	_register_joy_axis("nightfall_move_right", JOY_AXIS_LEFT_X, 1.0)
	_register_joy_axis("nightfall_move_up", JOY_AXIS_LEFT_Y, -1.0)
	_register_joy_axis("nightfall_move_down", JOY_AXIS_LEFT_Y, 1.0)
	_register_joy_axis("nightfall_aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_register_joy_axis("nightfall_aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_register_joy_axis("nightfall_aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_register_joy_axis("nightfall_aim_down", JOY_AXIS_RIGHT_Y, 1.0)
	_register_joy_button("nightfall_fire", JOY_BUTTON_RIGHT_SHOULDER)
	_register_joy_button("nightfall_ability", JOY_BUTTON_A)
	_register_joy_button("nightfall_dodge", JOY_BUTTON_B)

static func movement_vector() -> Vector2:
	return Input.get_vector("nightfall_move_left", "nightfall_move_right", "nightfall_move_up", "nightfall_move_down")

static func aim_vector() -> Vector2:
	return Input.get_vector("nightfall_aim_left", "nightfall_aim_right", "nightfall_aim_up", "nightfall_aim_down")

static func capture_gamepad_button(action: String, event: InputEventJoypadButton) -> bool:
	if not REMAPPABLE_ACTIONS.has(action) or not event.pressed:
		return false
	_ensure_action(action)
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadButton:
			InputMap.action_erase_event(action, existing)
	var captured := InputEventJoypadButton.new()
	captured.device = event.device
	captured.button_index = event.button_index
	InputMap.action_add_event(action, captured)
	_save_gamepad_bindings()
	return true

static func primary_gamepad_button(action: String) -> JoyButton:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return event.button_index
	return JOY_BUTTON_INVALID

static func action_for_gamepad_button(button: JoyButton, excluded_action: String = "") -> String:
	for action in REMAPPABLE_ACTIONS:
		if action == excluded_action:
			continue
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton and event.button_index == button:
				return action
	return ""

static func remove_gamepad_button(action: String, button: JoyButton) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button:
			InputMap.action_erase_event(action, event)
	_save_gamepad_bindings()

static func action_label(action: String) -> String:
	if action == "nightfall_fire":
		return "FIRE"
	if action == "nightfall_ability":
		return "VEIL"
	return action.to_upper()

static func button_label(button: JoyButton) -> String:
	var labels := {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_LEFT_SHOULDER: "L1", JOY_BUTTON_RIGHT_SHOULDER: "R1"}
	return labels.get(button, "BUTTON " + str(button))

static func load_gamepad_bindings() -> void:
	var config := ConfigFile.new()
	if config.load(GAMEPAD_BINDING_PATH) != OK:
		return
	for action in REMAPPABLE_ACTIONS:
		var button: Variant = config.get_value("bindings", action, null)
		if button is int:
			var event := InputEventJoypadButton.new()
			event.button_index = button
			event.pressed = true
			capture_gamepad_button(action, event)

static func _save_gamepad_bindings() -> void:
	var config := ConfigFile.new()
	for action in REMAPPABLE_ACTIONS:
		config.set_value("bindings", action, int(primary_gamepad_button(action)))
	config.save(GAMEPAD_BINDING_PATH)

static func _register_key(action: String, keycode: Key) -> void:
	_ensure_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

static func _register_joy_axis(action: String, axis: JoyAxis, value: float) -> void:
	_ensure_action(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)

static func _register_joy_button(action: String, button: JoyButton) -> void:
	_ensure_action(action)
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

static func _ensure_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
