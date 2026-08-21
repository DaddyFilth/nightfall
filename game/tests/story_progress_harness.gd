extends SceneTree

const StoryProgress = preload("res://scripts/gameplay/story_campaign_progress.gd")

func _init() -> void:
	var mission_one_open: bool = StoryProgress.can_start_from_defeated(1, 0)
	var mission_two_locked: bool = not StoryProgress.can_start_from_defeated(2, 0)
	var mission_two_open: bool = StoryProgress.can_start_from_defeated(2, 1)
	var mission_three_locked: bool = not StoryProgress.can_start_from_defeated(3, 1)
	var mission_three_open: bool = StoryProgress.can_start_from_defeated(3, 2)
	var mission_ten_locked: bool = not StoryProgress.can_start_from_defeated(10, 8)
	var mission_ten_open: bool = StoryProgress.can_start_from_defeated(10, 9)
	var mission_eleven_invalid: bool = not StoryProgress.can_start_from_defeated(11, 10)
	if mission_one_open and mission_two_locked and mission_two_open and mission_three_locked and mission_three_open and mission_ten_locked and mission_ten_open and mission_eleven_invalid:
		print("STORY_PROGRESS_PASS order=1_to_10 locks=verified")
		quit(0)
		return
	printerr("STORY_PROGRESS_FAIL mission_one=%s mission_two_locked=%s mission_two_open=%s mission_three_locked=%s mission_three_open=%s mission_ten_locked=%s mission_ten_open=%s mission_eleven_invalid=%s" % [mission_one_open, mission_two_locked, mission_two_open, mission_three_locked, mission_three_open, mission_ten_locked, mission_ten_open, mission_eleven_invalid])
	quit(1)
