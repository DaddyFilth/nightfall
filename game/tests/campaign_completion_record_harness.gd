extends SceneTree

const CompletionRecord = preload("res://scripts/integration/campaign_completion_record.gd")

func _init() -> void:
	var payload := CompletionRecord.build_payload(8, "THE THIRTEENTH BELL", 8)
	var valid: Dictionary = CompletionRecord.validate(payload)
	var invalid: Dictionary = CompletionRecord.validate({"schema": CompletionRecord.SCHEMA, "completedMission": 9, "defeatedThrough": 8, "completedTitle": "INVALID"})
	if valid.get("valid", false) and not invalid.get("valid", true):
		print("CAMPAIGN_COMPLETION_RECORD_PASS local=validated mission=8")
		quit(0)
		return
	printerr("CAMPAIGN_COMPLETION_RECORD_FAIL valid=%s invalid=%s" % [valid, invalid])
	quit(1)
