## StoryPanel.gd  –  full-screen narrative overlay
## Shows a story beat with a typewriter-style text effect, a decorative border,
## and a "Tap to continue" prompt.  Emits `dismissed` when the player taps.
extends Control

signal dismissed

# ── palette refs ─────────────────────────────────────────────────────────────
const COLOR_BG_STORY   := Color(0.03, 0.02, 0.12, 0.96)
const COLOR_BORDER     := Color(0.55, 0.35, 1.00, 0.80)
const COLOR_TEXT       := Color(0.90, 0.88, 1.00, 1.00)
const COLOR_SUBTITLE   := Color(0.55, 0.35, 1.00, 1.00)
const COLOR_HINT       := Color(0.50, 0.45, 0.70, 0.90)

const TYPEWRITER_SPEED := 38   # characters per second

# ── internal state ────────────────────────────────────────────────────────────
var _full_text:     String = ""
var _type_timer:    float  = 0.0
var _typing_done:   bool   = false
var _ready_to_dismiss: bool = false

# ── nodes ─────────────────────────────────────────────────────────────────────
var _bg:         ColorRect
var _title_lbl:  Label
var _body_lbl:   Label
var _hint_lbl:   Label
var _blink_timer: float = 0.0

# ── build ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_bg = ColorRect.new()
	_bg.color = COLOR_BG_STORY
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# Decorative border frame (four lines)
	const M := 24.0   # margin
	var vp := get_viewport_rect().size
	_add_frame_line(Vector2(M, M),            Vector2(vp.x - M, M))
	_add_frame_line(Vector2(vp.x - M, M),     Vector2(vp.x - M, vp.y - M))
	_add_frame_line(Vector2(vp.x - M, vp.y - M), Vector2(M, vp.y - M))
	_add_frame_line(Vector2(M, vp.y - M),     Vector2(M, M))

	# Corner ornaments
	for corner in [Vector2(M, M), Vector2(vp.x - M, M),
				   Vector2(M, vp.y - M), Vector2(vp.x - M, vp.y - M)]:
		_add_corner_dot(corner)

	# Title label
	_title_lbl = Label.new()
	_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_lbl.add_theme_font_size_override("font_size", 44)
	_title_lbl.add_theme_color_override("font_color", COLOR_SUBTITLE)
	_title_lbl.position = Vector2(M + 10, M + 30)
	_title_lbl.size     = Vector2(vp.x - 2 * M - 20, 60)
	add_child(_title_lbl)

	# Body label
	_body_lbl = Label.new()
	_body_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_body_lbl.add_theme_font_size_override("font_size", 30)
	_body_lbl.add_theme_color_override("font_color", COLOR_TEXT)
	_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_lbl.position = Vector2(M + 20, M + 110)
	_body_lbl.size     = Vector2(vp.x - 2 * M - 40, vp.y - 2 * M - 190)
	add_child(_body_lbl)

	# "Tap to continue" hint
	_hint_lbl = Label.new()
	_hint_lbl.text = "✦  Tap to continue  ✦"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_font_size_override("font_size", 26)
	_hint_lbl.add_theme_color_override("font_color", COLOR_HINT)
	_hint_lbl.modulate.a = 0.0
	_hint_lbl.position = Vector2(M + 10, vp.y - M - 70)
	_hint_lbl.size     = Vector2(vp.x - 2 * M - 20, 50)
	add_child(_hint_lbl)

# ── public API ────────────────────────────────────────────────────────────────
func show_story(level_title: String, body: String) -> void:
	_title_lbl.text  = level_title
	_full_text       = body
	_type_timer      = 0.0
	_typing_done     = false
	_ready_to_dismiss = false
	_body_lbl.text   = ""
	_hint_lbl.modulate.a = 0.0
	_blink_timer     = 0.0
	show()

# ── processing ────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# Typewriter
	if not _typing_done:
		_type_timer += delta
		var target := int(_type_timer * TYPEWRITER_SPEED)
		if target >= _full_text.length():
			_body_lbl.text = _full_text
			_typing_done   = true
			_ready_to_dismiss = true
		else:
			_body_lbl.text = _full_text.substr(0, target)
		return

	# Blink hint once typing is done
	_blink_timer += delta
	_hint_lbl.modulate.a = 0.55 + 0.45 * sin(_blink_timer * TAU * 1.2)

# ── input ─────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if not visible:
		return
	var tapped := (event is InputEventScreenTouch and event.pressed) or \
				  (event is InputEventMouseButton  and event.pressed and \
				   event.button_index == MOUSE_BUTTON_LEFT)
	if not tapped:
		return

	if not _typing_done:
		# Skip typewriter
		_body_lbl.text = _full_text
		_typing_done   = true
		_ready_to_dismiss = true
		get_viewport().set_input_as_handled()
		return

	if _ready_to_dismiss:
		get_viewport().set_input_as_handled()
		hide()
		emit_signal("dismissed")

# ── helpers ───────────────────────────────────────────────────────────────────
func _add_frame_line(a: Vector2, b: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(a)
	line.add_point(b)
	line.default_color = COLOR_BORDER
	line.width = 2.0
	add_child(line)

func _add_corner_dot(pos: Vector2) -> void:
	var dot := ColorRect.new()
	dot.color    = GameData.COLOR_GOLD
	dot.size     = Vector2(8, 8)
	dot.position = pos - Vector2(4, 4)
	add_child(dot)
