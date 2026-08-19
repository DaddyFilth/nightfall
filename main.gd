## main.gd  –  root scene controller
## Drives the full game loop: start menu → intro → pre-level story → level play
## → post-level story → next level.  Delegates audio to AudioManager, level
## state to LevelManager, and narrative display to StoryPanel.
extends Node2D

# ── palette (local aliases for ergonomics) ───────────────────────────────────
const COLOR_BG     := GameData.COLOR_BG
const COLOR_ACCENT := GameData.COLOR_ACCENT
const COLOR_GOLD   := GameData.COLOR_GOLD
const COLOR_CARD   := GameData.COLOR_CARD
const COLOR_STAR   := GameData.COLOR_STAR

# ── game-state machine ────────────────────────────────────────────────────────
enum State { START_MENU, INTRO, PRE_STORY, PLAYING, POST_STORY, LEVEL_COMPLETE, GAME_OVER }
var _state: State = State.START_MENU

# ── nodes ─────────────────────────────────────────────────────────────────────
var _bg:           ColorRect
var _star_layer:   Node2D
var _flash_rect:   ColorRect
var _story_panel:  Control   # StoryPanel instance
var _start_menu:   Control   # StartMenu instance
var _game_over_panel: Control  # end-of-run overlay

var _hud:          Control
var _level_banner: Label
var _score_card:   ColorRect
var _score_label:  Label
var _progress_bg:  ColorRect
var _progress_bar: ColorRect
var _tap_label:    Label
var _level_label:  Label
var _timer_label:  Label   # Time Attack countdown

# ── star pool ─────────────────────────────────────────────────────────────────
const STAR_COUNT      := 80
const STAR_SPEED_BASE := 40.0

var _stars:       Array = []
var _star_speed:  float = 1.0   # multiplier

# ── tweens / timers ───────────────────────────────────────────────────────────
var _tap_tween:   Tween
var _flash_timer: float = 0.0

# =============================================================================
func _ready() -> void:
	_build_background()
	_spawn_stars()
	_build_hud()
	_build_story_panel()
	_build_game_over_panel()
	_build_start_menu()
	_connect_level_signals()
	_show_start_menu()

# ── background layer ──────────────────────────────────────────────────────────
func _build_background() -> void:
	_bg = ColorRect.new()
	_bg.color = COLOR_BG
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	_star_layer = Node2D.new()
	add_child(_star_layer)

	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)

# ── HUD layer ─────────────────────────────────────────────────────────────────
func _build_hud() -> void:
	var vp := get_viewport_rect().size
	var cx := vp.x * 0.5

	_hud = Control.new()
	_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.modulate.a = 0.0   # fades in after intro
	add_child(_hud)

	# ── Title shadow + title ──────────────────────────────────────────────────
	var ts := Label.new()
	ts.text = "NIGHTFALL"
	ts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ts.add_theme_font_size_override("font_size", 72)
	ts.add_theme_color_override("font_color", Color(0, 0, 0, 0.40))
	ts.position = Vector2(cx - 220 + 4, 52 + 4)
	ts.size = Vector2(440, 90)
	_hud.add_child(ts)

	var t := Label.new()
	t.text = "NIGHTFALL"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 72)
	t.add_theme_color_override("font_color", COLOR_ACCENT)
	t.position = Vector2(cx - 220, 52)
	t.size = Vector2(440, 90)
	_hud.add_child(t)

	# ── Level banner ──────────────────────────────────────────────────────────
	_level_banner = Label.new()
	_level_banner.text = ""
	_level_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_banner.add_theme_font_size_override("font_size", 26)
	_level_banner.add_theme_color_override("font_color", Color(0.70, 0.60, 1.00))
	_level_banner.position = Vector2(cx - 200, 142)
	_level_banner.size = Vector2(400, 36)
	_hud.add_child(_level_banner)

	# ── Score card ────────────────────────────────────────────────────────────
	_score_card = ColorRect.new()
	_score_card.color = COLOR_CARD
	_score_card.position = Vector2(cx - 170, 188)
	_score_card.size = Vector2(340, 88)
	_score_card.pivot_offset = Vector2(170, 44)   # scale from centre
	_hud.add_child(_score_card)
	_add_border_line(_score_card, Vector2(0, 0),  Vector2(340, 0),  COLOR_ACCENT)
	_add_border_line(_score_card, Vector2(0, 88), Vector2(340, 88), COLOR_ACCENT)

	_score_label = Label.new()
	_score_label.text = "Score: 0"
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.add_theme_font_size_override("font_size", 52)
	_score_label.add_theme_color_override("font_color", Color.WHITE)
	_score_label.position = Vector2(cx - 170, 200)
	_score_label.size = Vector2(340, 64)
	_hud.add_child(_score_label)

	# ── Progress bar ─────────────────────────────────────────────────────────
	_progress_bg = ColorRect.new()
	_progress_bg.color = Color(0.12, 0.10, 0.25)
	_progress_bg.position = Vector2(cx - 170, 285)
	_progress_bg.size = Vector2(340, 14)
	_hud.add_child(_progress_bg)

	_progress_bar = ColorRect.new()
	_progress_bar.color = COLOR_ACCENT
	_progress_bar.position = Vector2(cx - 170, 285)
	_progress_bar.size = Vector2(0, 14)
	_hud.add_child(_progress_bar)

	# ── Level indicator (bottom-left) ─────────────────────────────────────────
	_level_label = Label.new()
	_level_label.text = "LVL 1"
	_level_label.add_theme_font_size_override("font_size", 24)
	_level_label.add_theme_color_override("font_color", Color(0.55, 0.50, 0.75))
	_level_label.position = Vector2(20, vp.y - 60)
	_level_label.size = Vector2(120, 36)
	_hud.add_child(_level_label)

	# ── Tap prompt ────────────────────────────────────────────────────────────
	_tap_label = Label.new()
	_tap_label.text = "Tap to begin!"
	_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap_label.add_theme_font_size_override("font_size", 40)
	_tap_label.add_theme_color_override("font_color", Color(0.80, 0.70, 1.00))
	_tap_label.position = Vector2(cx - 200, vp.y * 0.50)
	_tap_label.size = Vector2(400, 55)
	_hud.add_child(_tap_label)

	# ── Time Attack countdown (bottom-right, hidden by default) ───────────────
	_timer_label = Label.new()
	_timer_label.text = ""
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_timer_label.add_theme_font_size_override("font_size", 28)
	_timer_label.add_theme_color_override("font_color", GameData.COLOR_GOLD)
	_timer_label.position = Vector2(vp.x - 160, vp.y - 60)
	_timer_label.size = Vector2(140, 36)
	_timer_label.hide()
	_hud.add_child(_timer_label)

# ── story panel ───────────────────────────────────────────────────────────────
func _build_story_panel() -> void:
	_story_panel = load("res://StoryPanel.gd").new()
	add_child(_story_panel)
	_story_panel.hide()
	_story_panel.connect("dismissed", Callable(self, "_on_story_dismissed"))

# ── game-over / time-up panel ────────────────────────────────────────────────
func _build_game_over_panel() -> void:
	_game_over_panel = Control.new()
	_game_over_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_game_over_panel)
	_game_over_panel.hide()

	var vp := get_viewport_rect().size
	var cx := vp.x * 0.5

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.12, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_panel.add_child(bg)

	const M := 24.0
	for pts in [[Vector2(M,M), Vector2(vp.x-M,M)],
				[Vector2(vp.x-M,M), Vector2(vp.x-M,vp.y-M)],
				[Vector2(vp.x-M,vp.y-M), Vector2(M,vp.y-M)],
				[Vector2(M,vp.y-M), Vector2(M,M)]]:
		var l := Line2D.new(); l.add_point(pts[0]); l.add_point(pts[1])
		l.default_color = GameData.COLOR_ACCENT; l.width = 2.0
		_game_over_panel.add_child(l)

	var title_lbl := Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 52)
	title_lbl.add_theme_color_override("font_color", GameData.COLOR_GOLD)
	title_lbl.position = Vector2(cx - 220, vp.y * 0.28)
	title_lbl.size = Vector2(440, 70)
	_game_over_panel.add_child(title_lbl)

	var body_lbl := Label.new()
	body_lbl.name = "BodyLabel"
	body_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_lbl.add_theme_font_size_override("font_size", 30)
	body_lbl.add_theme_color_override("font_color", Color(0.90, 0.88, 1.00))
	body_lbl.position = Vector2(M + 20, vp.y * 0.28 + 80)
	body_lbl.size = Vector2(vp.x - 2*M - 40, 120)
	_game_over_panel.add_child(body_lbl)

	var hint_lbl := Label.new()
	hint_lbl.name = "HintLabel"
	hint_lbl.text = "✦  Tap to return to menu  ✦"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 26)
	hint_lbl.add_theme_color_override("font_color", Color(0.50, 0.45, 0.70))
	hint_lbl.position = Vector2(M + 10, vp.y - M - 70)
	hint_lbl.size = Vector2(vp.x - 2*M - 20, 50)
	_game_over_panel.add_child(hint_lbl)

# ── start menu ────────────────────────────────────────────────────────────────
func _build_start_menu() -> void:
	_start_menu = load("res://StartMenu.gd").new()
	add_child(_start_menu)
	_start_menu.hide()
	_start_menu.connect("start_game", Callable(self, "_on_start_game"))

func _show_start_menu() -> void:
	_state = State.START_MENU
	LevelManager.reset()
	_hud.modulate.a = 0.0
	_story_panel.hide()
	_game_over_panel.hide()
	_start_menu.show()

# ── level signals ─────────────────────────────────────────────────────────────
func _connect_level_signals() -> void:
	LevelManager.connect("level_started",    Callable(self, "_on_level_started"))
	LevelManager.connect("level_completed",  Callable(self, "_on_level_completed"))
	LevelManager.connect("danger_triggered", Callable(self, "_on_danger_triggered"))

# ── intro sequence ────────────────────────────────────────────────────────────
func _on_start_game() -> void:
	_start_menu.hide()
	LevelManager.reset()
	_run_intro()

func _run_intro() -> void:
	_state = State.INTRO
	AudioManager.play_music(1.0)
	# Fade-in tween for HUD
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_property(_hud, "modulate:a", 1.0, 1.4)
	tw.tween_callback(Callable(self, "_intro_finished"))

func _intro_finished() -> void:
	_show_pre_story()

# ── story flow ────────────────────────────────────────────────────────────────
func _show_pre_story() -> void:
	_state = State.PRE_STORY
	var d := LevelManager.current_data
	_story_panel.show_story("— " + d["title"] + " —", d["story_pre"])

func _show_post_story() -> void:
	var game_type := GameData.selected_game_type
	if game_type == GameData.GameType.TIME_ATTACK:
		# Time Attack ends with a score screen, then return to menu
		_show_time_attack_result()
		return
	_state = State.POST_STORY
	var d := LevelManager.current_data
	var title := "Chapter End" if game_type == GameData.GameType.STORY else "Night %d Clear" % d.get("id", 1)
	_story_panel.show_story(title, d["story_post"])

func _on_story_dismissed() -> void:
	match _state:
		State.PRE_STORY:
			LevelManager.begin_level()
		State.POST_STORY:
			_advance_to_next_level()

# ── Time Attack result screen ─────────────────────────────────────────────────
func _show_time_attack_result() -> void:
	_state = State.GAME_OVER
	_story_panel.hide()
	var score := LevelManager.taps_this_level
	var title_lbl := _game_over_panel.get_node("TitleLabel") as Label
	var body_lbl  := _game_over_panel.get_node("BodyLabel")  as Label
	title_lbl.text = "⏱  Time's Up!"
	body_lbl.text  = "You tapped %d times!\n\nCan you beat your score?" % score
	_game_over_panel.show()

# ── level events ──────────────────────────────────────────────────────────────
func _on_level_started(data: Dictionary) -> void:
	_state = State.PLAYING
	_star_speed = data.get("star_speed", 1.0)
	AudioManager.set_music_pitch(data.get("music_pitch", 1.0))

	var id: int = data.get("id", 1)
	_level_label.text  = "LVL %d" % id
	_level_banner.text = data.get("title", "")
	_tap_label.text    = "Tap!"
	_tap_label.add_theme_color_override("font_color", Color(0.80, 0.70, 1.00))
	_score_label.text  = "Score: 0"
	_score_label.add_theme_color_override("font_color", Color.WHITE)

	# Show countdown timer only in Time Attack mode
	if GameData.selected_game_type == GameData.GameType.TIME_ATTACK:
		_timer_label.show()
		_timer_label.text = "⏱ 30"
	else:
		_timer_label.hide()

	_apply_bg_color(data.get("bg_color", COLOR_BG))
	_update_progress_bar(0.0)

func _on_level_completed(_data: Dictionary) -> void:
	# Guard: ignore duplicate signals (e.g. Time Attack fires while await is live)
	if _state == State.LEVEL_COMPLETE or _state == State.PRE_STORY \
			or _state == State.POST_STORY or _state == State.GAME_OVER:
		return
	_state = State.LEVEL_COMPLETE
	AudioManager.play_sfx_level_up()
	_trigger_flash(Color(0.55, 0.35, 1.00))
	_tap_label.text = "Level Clear! ✦"
	_tap_label.add_theme_color_override("font_color", COLOR_GOLD)
	_update_progress_bar(1.0)
	await get_tree().create_timer(1.6).timeout
	_show_post_story()

func _on_danger_triggered(_taps_left: int) -> void:
	AudioManager.play_sfx_danger()
	_tap_label.add_theme_color_override("font_color", GameData.COLOR_DANGER)

func _advance_to_next_level() -> void:
	# Story mode ends after all chapters are complete.
	if GameData.selected_game_type == GameData.GameType.STORY and \
			LevelManager.current_index >= GameData.LEVELS.size() - 1:
		AudioManager.stop_music()
		_show_credits()
		return
	var new_data := LevelManager.advance()
	AudioManager.set_music_pitch(new_data.get("music_pitch", 1.0))
	_update_progress_bar(0.0)
	_show_pre_story()

# Show a simple end-of-story credits screen then return to menu.
func _show_credits() -> void:
	_state = State.GAME_OVER
	var title_lbl := _game_over_panel.get_node("TitleLabel") as Label
	var body_lbl  := _game_over_panel.get_node("BodyLabel")  as Label
	title_lbl.text = "✦  Dawn Breaks  ✦"
	body_lbl.text  = "You have survived the Nightfall.\n\nThank you for playing."
	_game_over_panel.show()

# ── tap handling ──────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	# Game-over panel: tap anywhere to return to menu
	if _state == State.GAME_OVER and _game_over_panel.visible:
		var tapped := (event is InputEventScreenTouch and event.pressed) or \
					  (event is InputEventMouseButton  and event.pressed and \
					   event.button_index == MOUSE_BUTTON_LEFT)
		if tapped:
			get_viewport().set_input_as_handled()
			AudioManager.stop_music()
			_show_start_menu()
		return

	if _state != State.PLAYING:
		return
	var tapped := (event is InputEventScreenTouch and event.pressed) or \
				  (event is InputEventMouseButton  and event.pressed and \
				   event.button_index == MOUSE_BUTTON_LEFT)
	if tapped:
		_on_tap()

func _on_tap() -> void:
	var done := LevelManager.register_tap()
	var taps := LevelManager.taps_this_level

	_score_label.text = "Score: %d" % taps
	_update_progress_bar(LevelManager.progress_ratio())

	var is_milestone := (taps % 10 == 0)
	if is_milestone:
		_tap_label.text = "✦ Milestone! ✦"
		_tap_label.add_theme_color_override("font_color", COLOR_GOLD)
		_score_label.add_theme_color_override("font_color", COLOR_GOLD)
		_trigger_flash(Color(1.0, 0.85, 0.2))
		AudioManager.play_sfx_milestone()
	else:
		_tap_label.text = "Keep going!"
		_tap_label.add_theme_color_override("font_color", Color(0.80, 0.70, 1.00))
		_score_label.add_theme_color_override("font_color", Color.WHITE)
		AudioManager.play_sfx_tap()

	# Bounce-scale score card
	if _tap_tween:
		_tap_tween.kill()
	_tap_tween = create_tween()
	_tap_tween.tween_property(_score_card, "scale", Vector2(1.06, 1.06), 0.07)
	_tap_tween.tween_property(_score_card, "scale", Vector2(1.00, 1.00), 0.10)

	if done:
		pass  # signal already handled via _on_level_completed

# ── _process ──────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	var vp := get_viewport_rect().size
	for s in _stars:
		var n: ColorRect = s["node"]
		n.position.y += STAR_SPEED_BASE * _star_speed * s["speed"] * delta
		if n.position.y > vp.y:
			n.position.y = -n.size.y
			n.position.x = randf_range(0, vp.x)

	if _flash_timer > 0.0:
		_flash_timer -= delta
		_flash_rect.color.a = clampf(_flash_timer / 0.35, 0.0, 0.4)

	# Time Attack live countdown
	if _state == State.PLAYING and \
			GameData.selected_game_type == GameData.GameType.TIME_ATTACK:
		var secs := ceili(LevelManager.time_attack_remaining)
		_timer_label.text = "⏱ %d" % secs
		if secs <= 5:
			_timer_label.add_theme_color_override("font_color", GameData.COLOR_DANGER)
		else:
			_timer_label.add_theme_color_override("font_color", GameData.COLOR_GOLD)
		_update_progress_bar(LevelManager.progress_ratio())

# ── helpers ───────────────────────────────────────────────────────────────────
func _spawn_stars() -> void:
	var vp := get_viewport_rect().size
	for _i in STAR_COUNT:
		var sz := randf_range(1.5, 4.5)
		var star := ColorRect.new()
		star.color    = COLOR_STAR
		star.size     = Vector2(sz, sz)
		star.position = Vector2(randf_range(0, vp.x), randf_range(0, vp.y))
		_star_layer.add_child(star)
		_stars.append({"node": star, "speed": randf_range(0.5, 2.0)})

func _trigger_flash(color: Color) -> void:
	_flash_rect.color   = color
	_flash_rect.color.a = 0.4
	_flash_timer        = 0.35

func _apply_bg_color(c: Color) -> void:
	var tw := create_tween()
	tw.tween_property(_bg, "color", c, 0.8)

func _update_progress_bar(ratio: float) -> void:
	var full_w: float = 340.0
	_progress_bar.size.x = full_w * ratio
	# Colour shifts gold as level nears completion
	_progress_bar.color = COLOR_ACCENT.lerp(COLOR_GOLD, ratio)

func _add_border_line(parent: Control, from: Vector2, to: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.default_color = color
	line.width = 2.0
	parent.add_child(line)

