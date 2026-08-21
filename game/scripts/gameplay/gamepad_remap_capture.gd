class_name GamepadRemapCapture
extends Node

const NightfallInput = preload("res://scripts/gameplay/nightfall_input.gd")

signal capture_started(action: String)
signal capture_completed(action: String, button: JoyButton)
signal capture_rejected(action: String)
signal binding_conflict(action: String, conflicting_action: String, button: JoyButton)
signal conflict_replaced(action: String, displaced_action: String, button: JoyButton)
var pending_action := ""
var pending_conflict_action := ""
var pending_conflict_button: JoyButton = JOY_BUTTON_INVALID

func begin_capture(action: String) -> bool:
	if not NightfallInput.REMAPPABLE_ACTIONS.has(action):
		capture_rejected.emit(action)
		return false
	pending_action = action
	pending_conflict_action = ""
	pending_conflict_button = JOY_BUTTON_INVALID
	capture_started.emit(action)
	return true

func cancel_capture() -> void:
	pending_action = ""
	pending_conflict_action = ""
	pending_conflict_button = JOY_BUTTON_INVALID

func confirm_conflict_replacement() -> bool:
	if pending_action.is_empty() or pending_conflict_action.is_empty() or pending_conflict_button == JOY_BUTTON_INVALID:
		return false
	NightfallInput.remove_gamepad_button(pending_conflict_action, pending_conflict_button)
	var event := InputEventJoypadButton.new()
	event.button_index = pending_conflict_button
	event.pressed = true
	var action := pending_action
	var displaced := pending_conflict_action
	if not NightfallInput.capture_gamepad_button(action, event):
		return false
	cancel_capture()
	conflict_replaced.emit(action, displaced, event.button_index)
	capture_completed.emit(action, event.button_index)
	return true

func _unhandled_input(event: InputEvent) -> void:
	if pending_action.is_empty() or not event is InputEventJoypadButton:
		return
	var gamepad_event := event as InputEventJoypadButton
	if not gamepad_event.pressed:
		return
	var conflicting_action := NightfallInput.action_for_gamepad_button(gamepad_event.button_index, pending_action)
	if not conflicting_action.is_empty():
		pending_conflict_action = conflicting_action
		pending_conflict_button = gamepad_event.button_index
		binding_conflict.emit(pending_action, conflicting_action, gamepad_event.button_index)
		return
	if NightfallInput.capture_gamepad_button(pending_action, gamepad_event):
		var captured_action := pending_action
		cancel_capture()
		capture_completed.emit(captured_action, gamepad_event.button_index)
