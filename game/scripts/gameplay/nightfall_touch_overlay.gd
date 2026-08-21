class_name NightfallTouchOverlay
extends Control

signal fire_requested
signal fire_hold_changed(held: bool)
signal ability_requested
signal dodge_requested

const JOYSTICK_NORMALIZED := Vector2(0.12, 0.82)
const FIRE_NORMALIZED := Vector2(0.87, 0.80)
const ABILITY_NORMALIZED := Vector2(0.74, 0.61)
const DODGE_NORMALIZED := Vector2(0.93, 0.57)
const MOUSE_TOUCH_ID := -2
const ACTION_FEEDBACK_SECONDS := 0.16

var move_touch_id := -1
var look_touch_id := -1
var virtual_move := Vector2.ZERO
var look_delta := Vector2.ZERO
var look_last_position := Vector2.ZERO
var look_input_enabled := true
var action_touch_ids: Dictionary = {}
var action_feedback: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Global input avoids missed controls when the 3D scene owns focus beneath this overlay.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _process(delta: float) -> void:
	if action_feedback.is_empty():
		return
	for action_name in action_feedback.keys():
		var remaining := maxf(0.0, float(action_feedback[action_name]) - delta)
		if remaining <= 0.0:
			action_feedback.erase(action_name)
		else:
			action_feedback[action_name] = remaining
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_handle_pointer_touch(touch.index, touch.position, touch.pressed)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_handle_pointer_drag(drag.index, drag.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pointer_touch(MOUSE_TOUCH_ID, event.position, event.pressed)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_handle_pointer_drag(MOUSE_TOUCH_ID, event.position)

func _handle_pointer_touch(pointer_id: int, point: Vector2, pressed: bool) -> void:
	if not pressed:
		if pointer_id == move_touch_id:
			move_touch_id = -1
			virtual_move = Vector2.ZERO
		if pointer_id == look_touch_id:
			look_touch_id = -1
		var released_action: String = str(action_touch_ids.get(pointer_id, ""))
		if released_action == "fire":
			fire_hold_changed.emit(false)
		action_touch_ids.erase(pointer_id)
		queue_redraw()
		return
	if pointer_id == move_touch_id or _inside_circle(point, joystick_center(), joystick_radius() * 1.75):
		move_touch_id = pointer_id
		_update_virtual_move(point)
		return
	if _trigger_action_once(pointer_id, point):
		return
	if not look_input_enabled:
		return
	look_touch_id = pointer_id
	look_last_position = point

func _handle_pointer_drag(pointer_id: int, point: Vector2) -> void:
	if pointer_id != move_touch_id:
		if pointer_id == look_touch_id:
			look_delta += point - look_last_position
			look_last_position = point
		return
	_update_virtual_move(point)

func _update_virtual_move(point: Vector2) -> void:
	virtual_move = ((point - joystick_center()) / maxf(1.0, joystick_radius())).limit_length(1.0)
	queue_redraw()

func _trigger_action_once(pointer_id: int, point: Vector2) -> bool:
	if action_touch_ids.has(pointer_id):
		return true
	if _inside_circle(point, fire_center(), fire_radius() + action_hit_padding()):
			action_touch_ids[pointer_id] = "fire"
			action_feedback["fire"] = ACTION_FEEDBACK_SECONDS
			fire_requested.emit()
			fire_hold_changed.emit(true)
	elif _inside_circle(point, ability_center(), ability_radius() + action_hit_padding()):
		action_touch_ids[pointer_id] = "ability"
		action_feedback["ability"] = ACTION_FEEDBACK_SECONDS
		ability_requested.emit()
	elif _inside_circle(point, dodge_center(), dodge_radius() + action_hit_padding()):
		action_touch_ids[pointer_id] = "dodge"
		action_feedback["dodge"] = ACTION_FEEDBACK_SECONDS
		dodge_requested.emit()
	queue_redraw()
	return action_touch_ids.has(pointer_id)

func joystick_center() -> Vector2:
	return _safe_center(JOYSTICK_NORMALIZED)

func fire_center() -> Vector2:
	return _safe_center(FIRE_NORMALIZED)

func ability_center() -> Vector2:
	return _safe_center(ABILITY_NORMALIZED)

func dodge_center() -> Vector2:
	return _safe_center(DODGE_NORMALIZED)

func joystick_radius() -> float:
	return _scaled_radius(72.0)

func fire_radius() -> float:
	return _scaled_radius(60.0)

func ability_radius() -> float:
	return _scaled_radius(46.0)

func dodge_radius() -> float:
	return _scaled_radius(42.0)

func action_hit_padding() -> float:
	return _scaled_radius(16.0)

func _safe_center(normalized: Vector2) -> Vector2:
	var size := get_viewport_rect().size
	var inset := maxf(28.0, minf(size.x, size.y) * 0.05)
	return Vector2(lerpf(inset, size.x - inset, normalized.x), lerpf(inset, size.y - inset, normalized.y))

func _scaled_radius(base: float) -> float:
	var size := get_viewport_rect().size
	return base * clampf(minf(size.x / 1280.0, size.y / 720.0), 0.78, 1.28)

func _inside_circle(point: Vector2, center: Vector2, radius: float) -> bool:
	return point.distance_squared_to(center) <= radius * radius

func _is_action_pressed(action_name: String) -> bool:
	return action_touch_ids.values().has(action_name)

func action_feedback_strength(action_name: String) -> float:
	return clampf(float(action_feedback.get(action_name, 0.0)) / ACTION_FEEDBACK_SECONDS, 0.0, 1.0)

func set_virtual_move(intent: Vector2) -> void:
	virtual_move = intent.limit_length(1.0)
	queue_redraw()

func consume_look_delta() -> Vector2:
	var consumed := look_delta
	look_delta = Vector2.ZERO
	return consumed

func set_look_input_enabled(value: bool) -> void:
	look_input_enabled = value
	if not look_input_enabled:
		look_touch_id = -1
		look_delta = Vector2.ZERO

func _draw() -> void:
	var stick_center := joystick_center()
	var stick_radius := joystick_radius()
	draw_circle(stick_center, stick_radius + 11.0, Color("05070966"))
	draw_circle(stick_center, stick_radius, Color("141A2199"))
	draw_arc(stick_center, stick_radius, 0, TAU, 40, Color("6EA8A3CC"), 2.0)
	draw_arc(stick_center, stick_radius * 0.54, 0, TAU, 32, Color("B68A3977"), 1.0)
	draw_circle(stick_center + virtual_move * stick_radius * 0.56, stick_radius * 0.34, Color("C6EDE3DD"))
	draw_string(ThemeDB.fallback_font, stick_center + Vector2(-19, stick_radius + 24), "MOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11.0, Color("EDE1C4"))
	var look_hint := Vector2(get_viewport_rect().size.x * 0.61, get_viewport_rect().size.y * 0.27)
	draw_arc(look_hint, 28.0, -PI * 0.84, PI * 0.16, 18, Color("9FCDD077"), 1.5)
	draw_string(ThemeDB.fallback_font, look_hint + Vector2(-27, 43), "DRAG TO AIM", HORIZONTAL_ALIGNMENT_LEFT, -1, 9.0, Color("BFDADC99"))
	_draw_action_button(fire_center(), fire_radius(), "fire", "FIRE", Color("B72E45"), Color("F9B1BE"), 15.0)
	_draw_action_button(ability_center(), ability_radius(), "ability", "VEIL", Color("526F87"), Color("BEE8EE"), 12.0)
	_draw_action_button(dodge_center(), dodge_radius(), "dodge", "DODGE", Color("3D7D70"), Color("B9F2E3"), 10.0)

func _draw_action_button(center: Vector2, radius: float, action_name: String, label: String, fill: Color, rim: Color, font_size: float) -> void:
	var pressed := _is_action_pressed(action_name)
	var feedback := action_feedback_strength(action_name)
	var visual_radius := radius * (1.0 + feedback * 0.10)
	var outer_color := fill.lightened(0.22) if pressed else Color("06090B99")
	var fill_color := fill.lightened(0.18 + feedback * 0.22) if pressed else fill.lightened(feedback * 0.16)
	draw_circle(center, visual_radius + 9.0 + feedback * 7.0, outer_color.lightened(feedback * 0.16))
	draw_circle(center, visual_radius, fill_color)
	draw_arc(center, visual_radius, 0, TAU, 36, rim.lightened(feedback * 0.24), 2.0 + feedback * 1.5)
	if feedback > 0.0:
		draw_arc(center, visual_radius + 14.0 + feedback * 9.0, -PI * 0.24, PI * 0.46, 18, rim.lightened(0.34), 1.4 + feedback)
	var label_size := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(ThemeDB.fallback_font, center - label_size * 0.5 + Vector2(0, font_size * 0.36), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
