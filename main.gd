extends Node2D

# ── state ──────────────────────────────────────────────────────────────────
var score: int = 0

# ── ui nodes ───────────────────────────────────────────────────────────────
var bg: ColorRect
var star_layer: Node2D
var score_card: ColorRect
var score_label: Label
var tap_label: Label
var flash_rect: ColorRect

# ── star pool ───────────────────────────────────────────────────────────────
const STAR_COUNT      := 80
const STAR_SPEED_MIN  := 20.0
const STAR_SPEED_MAX  := 80.0

# Each star: { node: ColorRect, speed: float }
var stars: Array = []

# ── palette ─────────────────────────────────────────────────────────────────
const COLOR_BG        := Color(0.04, 0.04, 0.14, 1.0)   # deep navy
const COLOR_ACCENT    := Color(0.55, 0.35, 1.00, 1.0)   # violet
const COLOR_GOLD      := Color(1.00, 0.80, 0.20, 1.0)   # milestone gold
const COLOR_CARD      := Color(0.10, 0.08, 0.22, 0.92)  # card bg
const COLOR_STAR      := Color(0.85, 0.85, 1.00, 0.80)  # star tint

# ── tweens / timers ─────────────────────────────────────────────────────────
var tap_tween: Tween
var flash_timer: float = 0.0

# ============================================================================
func _ready() -> void:
	_build_ui()
	_spawn_stars()

# ── build ────────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	var vp := get_viewport_rect().size
	var cx := vp.x * 0.5

	# Background
	bg = ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Star layer (drawn behind everything else)
	star_layer = Node2D.new()
	add_child(star_layer)

	# Flash overlay (milestone feedback)
	flash_rect = ColorRect.new()
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash_rect)

	# ── Title ──────────────────────────────────────────────────────────────
	var title_shadow := Label.new()
	title_shadow.text = "NIGHTFALL"
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.add_theme_font_size_override("font_size", 72)
	title_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.45))
	title_shadow.position = Vector2(cx - 220 + 4, 68 + 4)
	title_shadow.size = Vector2(440, 90)
	add_child(title_shadow)

	var title := Label.new()
	title.text = "NIGHTFALL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", COLOR_ACCENT)
	title.position = Vector2(cx - 220, 68)
	title.size = Vector2(440, 90)
	add_child(title)

	# ── Score card ─────────────────────────────────────────────────────────
	score_card = ColorRect.new()
	score_card.color = COLOR_CARD
	score_card.position = Vector2(cx - 170, 180)
	score_card.size = Vector2(340, 90)
	add_child(score_card)

	# Card border lines (top & bottom)
	_add_border_line(score_card, Vector2(0, 0), Vector2(340, 0), COLOR_ACCENT)
	_add_border_line(score_card, Vector2(0, 90), Vector2(340, 90), COLOR_ACCENT)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 52)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.position = Vector2(cx - 170, 193)
	score_label.size = Vector2(340, 65)
	add_child(score_label)

	# ── Tap prompt ─────────────────────────────────────────────────────────
	tap_label = Label.new()
	tap_label.text = "Tap to play!"
	tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tap_label.add_theme_font_size_override("font_size", 40)
	tap_label.add_theme_color_override("font_color", Color(0.80, 0.70, 1.00))
	tap_label.position = Vector2(cx - 200, vp.y * 0.50)
	tap_label.size = Vector2(400, 55)
	add_child(tap_label)

	# ── Milestone hint ─────────────────────────────────────────────────────
	var hint := Label.new()
	hint.text = "Every 10 taps = milestone ✦"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(0.55, 0.50, 0.75))
	hint.position = Vector2(cx - 200, vp.y - 80)
	hint.size = Vector2(400, 35)
	add_child(hint)

# Helper: add a thin 2-px line inside a parent Control
func _add_border_line(parent: Control, from: Vector2, to: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.default_color = color
	line.width = 2.0
	parent.add_child(line)

# ── Stars ────────────────────────────────────────────────────────────────────
func _spawn_stars() -> void:
	var vp := get_viewport_rect().size
	for i in STAR_COUNT:
		var size := randf_range(1.5, 4.5)
		var star := ColorRect.new()
		star.color = COLOR_STAR
		star.size = Vector2(size, size)
		star.position = Vector2(randf_range(0, vp.x), randf_range(0, vp.y))
		star_layer.add_child(star)
		stars.append({"node": star, "speed": randf_range(STAR_SPEED_MIN, STAR_SPEED_MAX)})

func _process(delta: float) -> void:
	var vp := get_viewport_rect().size
	for s in stars:
		var n: ColorRect = s["node"]
		n.position.y += s["speed"] * delta
		if n.position.y > vp.y:
			n.position.y = -n.size.y
			n.position.x = randf_range(0, vp.x)

	# Flash fade-out
	if flash_timer > 0.0:
		flash_timer -= delta
		flash_rect.color.a = clampf(flash_timer / 0.35, 0.0, 0.4)

# ── Input ────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_on_tap()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap()

func _on_tap() -> void:
	score += 1
	score_label.text = "Score: %d" % score

	var is_milestone := (score % 10 == 0)

	if is_milestone:
		tap_label.text = "✦ Milestone! ✦"
		tap_label.add_theme_color_override("font_color", COLOR_GOLD)
		score_label.add_theme_color_override("font_color", COLOR_GOLD)
		_trigger_flash(Color(1.0, 0.85, 0.2, 0.0))
	else:
		tap_label.text = "Keep tapping!"
		tap_label.add_theme_color_override("font_color", Color(0.80, 0.70, 1.00))
		score_label.add_theme_color_override("font_color", Color.WHITE)

	# Bounce-scale the score card
	if tap_tween:
		tap_tween.kill()
	tap_tween = create_tween()
	tap_tween.tween_property(score_card, "scale", Vector2(1.06, 1.06), 0.07)
	tap_tween.tween_property(score_card, "scale", Vector2(1.00, 1.00), 0.10)

func _trigger_flash(color: Color) -> void:
	flash_rect.color = color
	flash_rect.color.a = 0.4
	flash_timer = 0.35
