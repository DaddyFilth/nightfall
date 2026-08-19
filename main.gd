extends Node2D

var score: int = 0
var score_label: Label
var tap_label: Label
var bg: ColorRect

func _ready():
	_build_ui()

func _build_ui():
	bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title = Label.new()
	title.text = "NIGHTFALL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(get_viewport_rect().size.x / 2.0 - 200, 80)
	title.size = Vector2(400, 80)
	add_child(title)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 48)
	score_label.position = Vector2(get_viewport_rect().size.x / 2.0 - 200, 200)
	score_label.size = Vector2(400, 60)
	add_child(score_label)

	tap_label = Label.new()
	tap_label.text = "Tap to play!"
	tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tap_label.add_theme_font_size_override("font_size", 36)
	tap_label.position = Vector2(get_viewport_rect().size.x / 2.0 - 200, get_viewport_rect().size.y / 2.0)
	tap_label.size = Vector2(400, 50)
	add_child(tap_label)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		_on_tap()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap()

func _on_tap():
	score += 1
	score_label.text = "Score: %d" % score
	tap_label.text = "Keep tapping!"
