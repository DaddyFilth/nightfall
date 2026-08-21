class_name FpsCampaignHub
extends Control

const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const StoryProgress = preload("res://scripts/gameplay/story_campaign_progress.gd")
const FpsClassRoster = preload("res://scripts/gameplay/fps_class_roster.gd")
const SCENE_PATHS := [
	"res://scenes/brasswake_combat.tscn",
	"res://scenes/the_broken_compass.tscn",
	"res://scenes/the_observatory_campaign.tscn",
	"res://scenes/sable_wake.tscn",
	"res://scenes/lanterns_of_the_lost.tscn",
	"res://scenes/iron_cathedral.tscn",
	"res://scenes/coffin_fleet.tscn",
	"res://scenes/the_thirteenth_bell.tscn",
	"res://scenes/red_meridian.tscn",
	"res://scenes/blood_and_brass_finale.tscn"
]
var selected_class_id := FpsClassRoster.DEFAULT_CLASS_ID
var class_summary: Label
var class_buttons: Dictionary = {}

func _ready() -> void:
	name = "BloodAndBrassCampaignHub"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selected_class_id = FpsClassRoster.selected_class_id()
	_build_roster()

func _build_roster() -> void:
	var background := ColorRect.new()
	background.name = "CampaignHubBackground"
	background.color = Color("0D0A14")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var brass_line := ColorRect.new()
	brass_line.color = Color("C7973A")
	brass_line.position = Vector2(0, 0)
	brass_line.size = Vector2(1280, 4)
	brass_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(brass_line)
	var title := Label.new()
	title.name = "CampaignHubTitle"
	title.text = "BLOOD & BRASS // THE DROWNED CHART"
	title.position = Vector2(36, 24)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("EDE1C4"))
	title.add_theme_color_override("font_outline_color", Color("080604"))
	title.add_theme_constant_override("outline_size", 5)
	add_child(title)
	var briefing := Label.new()
	briefing.name = "CampaignHubBriefing"
	briefing.text = "TEN ANIMATED FIRST-PERSON CAMPAIGN LEVELS // 3–6 CHECKPOINTS EACH // COMPLETE LEVELS IN ORDER"
	briefing.position = Vector2(38, 60)
	briefing.add_theme_font_size_override("font_size", 11)
	briefing.add_theme_color_override("font_color", Color("9FCDD0"))
	add_child(briefing)
	var progress := Label.new()
	progress.name = "CampaignHubProgress"
	progress.text = "LOCAL CLEARANCE // %02d / %02d" % [StoryProgress.defeated_through(), CampaignRoster.level_count()]
	progress.position = Vector2(1002, 34)
	progress.size = Vector2(240, 24)
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	progress.add_theme_font_size_override("font_size", 12)
	progress.add_theme_color_override("font_color", Color("E7CB63"))
	add_child(progress)
	var class_frame := ColorRect.new()
	class_frame.name = "BloodHuntClassSelection"
	class_frame.position = Vector2(32, 92)
	class_frame.size = Vector2(1216, 92)
	class_frame.color = Color("140F14E8")
	add_child(class_frame)
	var class_title := Label.new()
	class_title.text = "SELECT FIRST-PERSON BLOODLINE // SIX LOCAL COMBAT STYLES"
	class_title.position = Vector2(18, 10)
	class_title.add_theme_font_size_override("font_size", 12)
	class_title.add_theme_color_override("font_color", Color("EDE1C4"))
	class_frame.add_child(class_title)
	class_summary = Label.new()
	class_summary.name = "SelectedClassSummary"
	class_summary.position = Vector2(18, 32)
	class_summary.size = Vector2(940, 18)
	class_summary.add_theme_font_size_override("font_size", 10)
	class_summary.add_theme_color_override("font_color", Color("A9CAC7"))
	class_frame.add_child(class_summary)
	var class_selector := HBoxContainer.new()
	class_selector.name = "ClassSelector"
	class_selector.position = Vector2(18, 56)
	class_selector.size = Vector2(940, 28)
	class_selector.add_theme_constant_override("separation", 7)
	class_frame.add_child(class_selector)
	for class_id in FpsClassRoster.CLASS_IDS:
		var profile := FpsClassRoster.profile(class_id)
		var class_button := Button.new()
		class_button.name = "ClassButton_%s" % class_id
		class_button.custom_minimum_size = Vector2(180, 27)
		class_button.text = str(profile.get("callsign", class_id)).to_upper()
		class_button.add_theme_font_size_override("font_size", 9)
		class_button.pressed.connect(_select_class.bind(class_id))
		class_selector.add_child(class_button)
		class_buttons[class_id] = class_button
	var explore_button := Button.new()
	explore_button.name = "ExploreBrasswakeButton"
	explore_button.text = "EXPLORE BRASSWAKE"
	explore_button.position = Vector2(984, 42)
	explore_button.size = Vector2(212, 34)
	explore_button.add_theme_font_size_override("font_size", 10)
	explore_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/open_world_hub.tscn"))
	class_frame.add_child(explore_button)
	_refresh_class_selection()
	var scroll := ScrollContainer.new()
	scroll.name = "CampaignLevelScroll"
	scroll.position = Vector2(32, 194)
	scroll.size = Vector2(1216, 486)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "CampaignLevelGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for level_id in range(1, CampaignRoster.level_count() + 1):
		var unlocked := StoryProgress.can_start(level_id)
		var button := Button.new()
		button.name = "MissionButton_%02d" % level_id
		button.custom_minimum_size = Vector2(592, 94)
		button.disabled = not unlocked
		button.text = _mission_button_label(level_id, unlocked)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", Color("EDE1C4") if unlocked else Color("82755F"))
		button.pressed.connect(_launch_level.bind(level_id))
		grid.add_child(button)

func _mission_button_label(level_id: int, unlocked: bool) -> String:
	var title := CampaignRoster.level_title(level_id)
	var checkpoints := CampaignRoster.checkpoint_count(level_id)
	var state := "DEPLOY FIRST-PERSON MISSION" if unlocked else "LOCKED // DEFEAT LEVEL %02d" % max(1, level_id - 1)
	var callsign := str(FpsClassRoster.profile(selected_class_id).get("callsign", "DUELIST"))
	return "LEVEL %02d // %s\n%s // %d CHECKPOINTS // %s\n%s" % [level_id, title, str(CampaignRoster.level(level_id).get("subtitle", "")), checkpoints, callsign, state]

func _select_class(class_id: String) -> void:
	selected_class_id = FpsClassRoster.save_selected_class(class_id)
	_refresh_class_selection()
	for level_id in range(1, CampaignRoster.level_count() + 1):
		var button := get_node_or_null("CampaignLevelScroll/CampaignLevelGrid/MissionButton_%02d" % level_id) as Button
		if button:
			button.text = _mission_button_label(level_id, StoryProgress.can_start(level_id))

func _refresh_class_selection() -> void:
	var profile := FpsClassRoster.profile(selected_class_id)
	if class_summary:
		class_summary.text = "%s // %s // %s + %s" % [str(profile.get("label", "BLOODWAKE CAPTAIN")), str(profile.get("style", "")), str(profile.get("primary_weapon", "")), str(profile.get("secondary_weapon", ""))]
	for class_id in class_buttons:
		var button := class_buttons[class_id] as Button
		var profile_for_button := FpsClassRoster.profile(str(class_id))
		button.disabled = str(class_id) == selected_class_id
		button.add_theme_color_override("font_color", profile_for_button.get("accent", Color("EDE1C4")) as Color)

func _launch_level(level_id: int) -> void:
	if not StoryProgress.can_start(level_id):
		return
	FpsClassRoster.save_selected_class(selected_class_id)
	get_tree().change_scene_to_file(SCENE_PATHS[level_id - 1])
