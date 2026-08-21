class_name GamepadRebindPrompt
extends CanvasLayer

const NightfallInput = preload("res://scripts/gameplay/nightfall_input.gd")
var status: Label
var detail: Label
var capture: Node

func _ready() -> void:
	name = "GamepadRebindPrompt"
	var panel := ColorRect.new()
	panel.color = Color("10101ADD")
	panel.position = Vector2(20, 150)
	panel.size = Vector2(335, 104)
	add_child(panel)
	status = Label.new()
	status.position = Vector2(34, 164)
	status.add_theme_font_size_override("font_size", 15)
	status.add_theme_color_override("font_color", Color("F5F0E9"))
	add_child(status)
	detail = Label.new()
	detail.position = Vector2(34, 193)
	detail.size = Vector2(304, 50)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 11)
	detail.add_theme_color_override("font_color", Color("A9A3B5"))
	add_child(detail)
	show_idle()

func attach(source: Node) -> void:
	capture = source
	source.connect("capture_started", _on_capture_started)
	source.connect("binding_conflict", _on_conflict)
	source.connect("capture_completed", _on_capture_completed)
	source.connect("conflict_replaced", _on_conflict_replaced)

func request_capture(action: String) -> void:
	if capture:
		capture.call("begin_capture", action)

func confirm_replace() -> void:
	if capture:
		capture.call("confirm_conflict_replacement")

func show_idle() -> void:
	status.text = "GAMEPAD REBINDING"
	detail.text = "Capture is available for FIRE and VEIL. New buttons are stored locally in this Godot runtime."

func _on_capture_started(action: String) -> void:
	status.text = "PRESS A BUTTON FOR " + NightfallInput.action_label(action)
	detail.text = "Press any gamepad button. Existing action bindings will be checked before replacement."

func _on_conflict(action: String, conflicting_action: String, button: JoyButton) -> void:
	status.text = NightfallInput.button_label(button) + " IS BOUND TO " + NightfallInput.action_label(conflicting_action)
	detail.text = "Confirm replacement to move " + NightfallInput.button_label(button) + " to " + NightfallInput.action_label(action) + ". The prior binding will be removed."

func _on_capture_completed(action: String, button: JoyButton) -> void:
	status.text = NightfallInput.action_label(action) + " BOUND TO " + NightfallInput.button_label(button)
	detail.text = "Binding saved locally."

func _on_conflict_replaced(action: String, displaced_action: String, button: JoyButton) -> void:
	status.text = NightfallInput.button_label(button) + " MOVED TO " + NightfallInput.action_label(action)
	detail.text = NightfallInput.action_label(displaced_action) + " no longer uses that button. Binding saved locally."
