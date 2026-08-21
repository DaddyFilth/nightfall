extends SceneTree

const CampaignHub = preload("res://scenes/campaign_hub.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var hub := CampaignHub.instantiate()
	root.add_child(hub)
	await process_frame
	var grid := hub.get_node_or_null("CampaignLevelScroll/CampaignLevelGrid") as GridContainer
	var first := hub.get_node_or_null("CampaignLevelScroll/CampaignLevelGrid/MissionButton_01") as Button
	var second := hub.get_node_or_null("CampaignLevelScroll/CampaignLevelGrid/MissionButton_02") as Button
	var finale := hub.get_node_or_null("CampaignLevelScroll/CampaignLevelGrid/MissionButton_10") as Button
	if grid and grid.get_child_count() == 10 and first and not first.disabled and second and second.disabled and finale and finale.disabled:
		print("CAMPAIGN_HUB_PASS roster=10 level_one=open later_levels=locked")
		quit(0)
		return
	printerr("CAMPAIGN_HUB_FAIL grid=%s children=%s first=%s second=%s finale=%s" % [grid != null, grid.get_child_count() if grid else -1, first.disabled if first else "missing", second.disabled if second else "missing", finale.disabled if finale else "missing"])
	quit(1)
