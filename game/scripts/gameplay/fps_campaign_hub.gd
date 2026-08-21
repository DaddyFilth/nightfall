class_name FpsCampaignHub
extends Control

const CampaignRoster = preload("res://scripts/gameplay/campaign_roster.gd")
const StoryProgress = preload("res://scripts/gameplay/story_campaign_progress.gd")
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

func _ready() -> void:
	name = "BloodAndBrassCampaignHub"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	var scroll := ScrollContainer.new()
	scroll.name = "CampaignLevelScroll"
	scroll.position = Vector2(32, 96)
	scroll.size = Vector2(1216, 584)
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
	return "LEVEL %02d // %s\n%s // %d CHECKPOINTS\n%s" % [level_id, title, str(CampaignRoster.level(level_id).get("subtitle", "")), checkpoints, state]

func _launch_level(level_id: int) -> void:
	if not StoryProgress.can_start(level_id):
		return
	get_tree().change_scene_to_file(SCENE_PATHS[level_id - 1])
