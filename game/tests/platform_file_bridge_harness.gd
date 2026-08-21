extends SceneTree

const Bridge = preload("res://scripts/integration/platform_preference_file_bridge.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall/import"))
	var payload := {"schema": "nightfall.godot-preferences.v1", "preferences": {"sensitivity": 70, "reducedMotion": false, "highContrastReticle": false, "subtitles": true, "colorMarkers": true, "vibration": true, "audioCueSubtitles": true, "touchLayout": "right_handed", "touchPrimaryAction": "fire"}, "campaign": {"observatoryBranch": "last_platform"}}
	var inbox := FileAccess.open(Bridge.INBOX_PATH, FileAccess.WRITE)
	inbox.store_string(JSON.stringify(payload))
	inbox.close()
	var installed: Dictionary = Bridge.install_inbox()
	_assert(installed["installed"], "install")
	var active: Dictionary = Bridge.read_active()
	_assert(active["found"], "read_active")
	_assert(active["payload"]["campaign"]["observatoryBranch"] == "last_platform", "branch_preserved")
	var invalid := FileAccess.open(Bridge.INBOX_PATH, FileAccess.WRITE)
	invalid.store_string("{bad json")
	invalid.close()
	var rejected: Dictionary = Bridge.install_inbox()
	_assert(not rejected["installed"] and rejected["reason"] == "json", "invalid_rejected")
	print("PLATFORM_FILE_BRIDGE_PASS sandbox=user schema=validated install=atomic")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("PLATFORM_FILE_BRIDGE_FAIL " + label)
		quit(1)
