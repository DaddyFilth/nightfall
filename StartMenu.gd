## StartMenu.gd  –  full-screen start menu
## Presents game-type and difficulty selectors, then emits `start_game` when
## the player taps the Start button.
extends Control

signal start_game

# ── palette ───────────────────────────────────────────────────────────────────
const COLOR_BG      := Color(0.04, 0.04, 0.14, 1.0)
const COLOR_ACCENT  := Color(0.55, 0.35, 1.00, 1.0)
const COLOR_GOLD    := Color(1.00, 0.80, 0.20, 1.0)
const COLOR_CARD    := Color(0.10, 0.08, 0.22, 0.95)
const COLOR_BORDER  := Color(0.55, 0.35, 1.00, 0.80)
const COLOR_TEXT    := Color(0.90, 0.88, 1.00, 1.00)
const COLOR_DIM     := Color(0.50, 0.45, 0.70, 0.90)
const COLOR_SELECT  := Color(1.00, 0.80, 0.20, 1.00)  # gold highlight

# ── nodes ─────────────────────────────────────────────────────────────────────
var _bg:            ColorRect
var _star_layer:    Node2D
var _stars:         Array = []

var _type_buttons:  Array = []   # Array[ColorRect]  – one per GameType
var _diff_buttons:  Array = []   # Array[ColorRect]  – one per Difficulty
var _start_btn:     ColorRect

var _type_labels:   Array = []
var _diff_labels:   Array = []

# ── star pool ─────────────────────────────────────────────────────────────────
const STAR_COUNT      := 60
const STAR_SPEED_BASE := 35.0

# =============================================================================
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_background()
	_build_ui()

# ── background ────────────────────────────────────────────────────────────────
func _build_background() -> void:
	_bg = ColorRect.new()
	_bg.color = COLOR_BG
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	_star_layer = Node2D.new()
	add_child(_star_layer)

	var vp := get_viewport_rect().size
	for _i in STAR_COUNT:
		var sz  := randf_range(1.5, 4.0)
		var star := ColorRect.new()
		star.color    = Color(0.85, 0.85, 1.00, 0.70)
		star.size     = Vector2(sz, sz)
		star.position = Vector2(randf_range(0, vp.x), randf_range(0, vp.y))
		_star_layer.add_child(star)
		_stars.append({"node": star, "speed": randf_range(0.5, 2.0)})

# ── UI layout ─────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	var vp := get_viewport_rect().size
	var cx := vp.x * 0.5

	# ── Decorative border frame ───────────────────────────────────────────────
	const M := 20.0
	_add_frame_line(Vector2(M, M),             Vector2(vp.x - M, M))
	_add_frame_line(Vector2(vp.x - M, M),      Vector2(vp.x - M, vp.y - M))
	_add_frame_line(Vector2(vp.x - M, vp.y - M), Vector2(M, vp.y - M))
	_add_frame_line(Vector2(M, vp.y - M),      Vector2(M, M))
	for corner in [Vector2(M, M), Vector2(vp.x - M, M),
				   Vector2(M, vp.y - M), Vector2(vp.x - M, vp.y - M)]:
		var dot := ColorRect.new()
		dot.color    = COLOR_GOLD
		dot.size     = Vector2(8, 8)
		dot.position = corner - Vector2(4, 4)
		add_child(dot)

	# ── Title ─────────────────────────────────────────────────────────────────
	var title_shadow := Label.new()
	title_shadow.text = "NIGHTFALL"
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.add_theme_font_size_override("font_size", 72)
	title_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.40))
	title_shadow.position = Vector2(cx - 220 + 4, 44 + 4)
	title_shadow.size = Vector2(440, 90)
	add_child(title_shadow)

	var title := Label.new()
	title.text = "NIGHTFALL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", COLOR_ACCENT)
	title.position = Vector2(cx - 220, 44)
	title.size = Vector2(440, 90)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "✦  Choose your journey  ✦"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", COLOR_DIM)
	subtitle.position = Vector2(cx - 200, 130)
	subtitle.size = Vector2(400, 32)
	add_child(subtitle)

	# ── Section: Game Type ────────────────────────────────────────────────────
	var gt_y := 180.0
	var gt_heading := Label.new()
	gt_heading.text = "GAME TYPE"
	gt_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gt_heading.add_theme_font_size_override("font_size", 26)
	gt_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	gt_heading.position = Vector2(cx - 200, gt_y)
	gt_heading.size = Vector2(400, 34)
	add_child(gt_heading)

	var gt_desc_texts := [
		"Follow the story through 5 chapters",
		"Endless escalating waves",
		"Race against a 30-second timer",
	]
	var btn_w  := 280.0
	var btn_h  := 58.0
	var btn_gap := 10.0
	var btn_x  := cx - btn_w * 0.5

	for i in GameData.GAME_TYPE_LABELS.size():
		var card := _make_card(
			Vector2(btn_x, gt_y + 38 + i * (btn_h + btn_gap)),
			Vector2(btn_w, btn_h),
			GameData.GAME_TYPE_LABELS[i],
			gt_desc_texts[i]
		)
		_type_buttons.append(card)
		_type_labels.append(card.get_child(card.get_child_count() - 2))  # title label
		card.gui_input.connect(_on_type_card_input.bind(i))

	# ── Section: Difficulty ───────────────────────────────────────────────────
	var df_y := gt_y + 38 + GameData.GAME_TYPE_LABELS.size() * (btn_h + btn_gap) + 24
	var df_heading := Label.new()
	df_heading.text = "DIFFICULTY"
	df_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	df_heading.add_theme_font_size_override("font_size", 26)
	df_heading.add_theme_color_override("font_color", COLOR_ACCENT)
	df_heading.position = Vector2(cx - 200, df_y)
	df_heading.size = Vector2(400, 34)
	add_child(df_heading)

	var diff_desc_texts := [
		"Fewer taps, slower stars",
		"The classic Nightfall experience",
		"More taps, faster stars",
	]
	for i in GameData.DIFFICULTY_LABELS.size():
		var card := _make_card(
			Vector2(btn_x, df_y + 38 + i * (btn_h + btn_gap)),
			Vector2(btn_w, btn_h),
			GameData.DIFFICULTY_LABELS[i],
			diff_desc_texts[i]
		)
		_diff_buttons.append(card)
		_diff_labels.append(card.get_child(card.get_child_count() - 2))
		card.gui_input.connect(_on_diff_card_input.bind(i))

	# ── Start button ──────────────────────────────────────────────────────────
	var start_y := df_y + 38 + GameData.DIFFICULTY_LABELS.size() * (btn_h + btn_gap) + 28
	_start_btn = ColorRect.new()
	_start_btn.color    = COLOR_ACCENT
	_start_btn.position = Vector2(cx - 120, start_y)
	_start_btn.size     = Vector2(240, 62)
	add_child(_start_btn)

	var start_lbl := Label.new()
	start_lbl.text = "▶  START"
	start_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	start_lbl.add_theme_font_size_override("font_size", 34)
	start_lbl.add_theme_color_override("font_color", Color.WHITE)
	start_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_start_btn.add_child(start_lbl)

	_start_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_btn.gui_input.connect(_on_start_pressed)

	# Apply initial selection highlights
	_refresh_type_highlight()
	_refresh_diff_highlight()

# ── card factory ──────────────────────────────────────────────────────────────
func _make_card(pos: Vector2, sz: Vector2, title: String, desc: String) -> ColorRect:
	var card := ColorRect.new()
	card.color       = COLOR_CARD
	card.position    = pos
	card.size        = sz
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(card)

	_add_card_border(card, sz)

	var lbl := Label.new()
	lbl.text = title
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_color", COLOR_TEXT)
	lbl.position = Vector2(14, 6)
	lbl.size     = Vector2(sz.x - 28, 28)
	card.add_child(lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = desc
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc_lbl.add_theme_font_size_override("font_size", 16)
	desc_lbl.add_theme_color_override("font_color", COLOR_DIM)
	desc_lbl.position = Vector2(14, 32)
	desc_lbl.size     = Vector2(sz.x - 28, 22)
	card.add_child(desc_lbl)

	return card

func _add_card_border(card: ColorRect, sz: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(Vector2(0, 0))
	line.add_point(Vector2(sz.x, 0))
	line.add_point(Vector2(sz.x, sz.y))
	line.add_point(Vector2(0, sz.y))
	line.add_point(Vector2(0, 0))
	line.default_color = COLOR_BORDER
	line.width = 1.5
	card.add_child(line)

# ── highlight helpers ─────────────────────────────────────────────────────────
func _refresh_type_highlight() -> void:
	for i in _type_buttons.size():
		var card: ColorRect = _type_buttons[i]
		var lbl: Label      = _type_labels[i]
		if i == GameData.selected_game_type:
			card.color = Color(0.16, 0.10, 0.34, 0.98)
			lbl.add_theme_color_override("font_color", COLOR_SELECT)
		else:
			card.color = COLOR_CARD
			lbl.add_theme_color_override("font_color", COLOR_TEXT)

func _refresh_diff_highlight() -> void:
	for i in _diff_buttons.size():
		var card: ColorRect = _diff_buttons[i]
		var lbl: Label      = _diff_labels[i]
		if i == GameData.selected_difficulty:
			card.color = Color(0.16, 0.10, 0.34, 0.98)
			lbl.add_theme_color_override("font_color", COLOR_SELECT)
		else:
			card.color = COLOR_CARD
			lbl.add_theme_color_override("font_color", COLOR_TEXT)

# ── input handlers ────────────────────────────────────────────────────────────
func _on_type_card_input(event: InputEvent, idx: int) -> void:
	if _is_tap(event):
		GameData.selected_game_type = idx
		_refresh_type_highlight()
		get_viewport().set_input_as_handled()

func _on_diff_card_input(event: InputEvent, idx: int) -> void:
	if _is_tap(event):
		GameData.selected_difficulty = idx
		_refresh_diff_highlight()
		get_viewport().set_input_as_handled()

func _on_start_pressed(event: InputEvent) -> void:
	if _is_tap(event):
		get_viewport().set_input_as_handled()
		_animate_start()

func _animate_start() -> void:
	var tw := create_tween()
	tw.tween_property(_start_btn, "scale", Vector2(0.92, 0.92), 0.07)
	tw.tween_property(_start_btn, "scale", Vector2(1.00, 1.00), 0.08)
	tw.tween_callback(Callable(self, "_emit_start"))

func _emit_start() -> void:
	emit_signal("start_game")

# ── _process ──────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	var vp := get_viewport_rect().size
	for s in _stars:
		var n: ColorRect = s["node"]
		n.position.y += STAR_SPEED_BASE * s["speed"] * delta
		if n.position.y > vp.y:
			n.position.y = -n.size.y
			n.position.x = randf_range(0, vp.x)

# ── helpers ───────────────────────────────────────────────────────────────────
func _is_tap(event: InputEvent) -> bool:
	return (event is InputEventScreenTouch and event.pressed) or \
		   (event is InputEventMouseButton  and event.pressed and \
		    event.button_index == MOUSE_BUTTON_LEFT)

func _add_frame_line(a: Vector2, b: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(a)
	line.add_point(b)
	line.default_color = COLOR_BORDER
	line.width = 2.0
	add_child(line)
