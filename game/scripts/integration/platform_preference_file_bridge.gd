class_name PlatformPreferenceFileBridge
extends RefCounted

const INBOX_PATH := "user://nightfall/import/expo-preferences.v1.json"
const ACTIVE_PATH := "user://nightfall/expo-preferences.v1.json"
const TEMP_PATH := "user://nightfall/expo-preferences.v1.tmp"
const Handoff = preload("res://scripts/integration/expo_preference_handoff.gd")

static func install_inbox() -> Dictionary:
	if not FileAccess.file_exists(INBOX_PATH):
		return {"installed": false, "reason": "inbox_missing"}
	var input := FileAccess.open(INBOX_PATH, FileAccess.READ)
	if input == null:
		return {"installed": false, "reason": "inbox_unreadable"}
	var parse := JSON.new()
	if parse.parse(input.get_as_text()) != OK or not parse.data is Dictionary:
		return {"installed": false, "reason": "json"}
	var payload: Dictionary = parse.data
	return install_payload(payload)

static func install_payload(payload: Dictionary) -> Dictionary:
	var validation := Handoff.validate(payload)
	if not validation["valid"]:
		return {"installed": false, "reason": "invalid_" + String(validation["reason"])}
	return _atomic_write(payload)

static func _atomic_write(payload: Dictionary) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall"))
	var temp := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if temp == null:
		return {"installed": false, "reason": "temp_unwritable"}
	temp.store_string(JSON.stringify(payload))
	temp.flush()
	temp.close()
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(TEMP_PATH), ProjectSettings.globalize_path(ACTIVE_PATH))
	if rename_error != OK:
		return {"installed": false, "reason": "replace_failed"}
	return {"installed": true, "reason": "ok", "path": ACTIVE_PATH}

static func read_active() -> Dictionary:
	if not FileAccess.file_exists(ACTIVE_PATH):
		return {"found": false, "reason": "active_missing"}
	var active := FileAccess.open(ACTIVE_PATH, FileAccess.READ)
	if active == null:
		return {"found": false, "reason": "active_unreadable"}
	var parse := JSON.new()
	if parse.parse(active.get_as_text()) != OK or not parse.data is Dictionary:
		return {"found": false, "reason": "active_json"}
	var payload: Dictionary = parse.data
	var validation := Handoff.validate(payload)
	if not validation["valid"]:
		return {"found": false, "reason": "active_invalid"}
	return {"found": true, "reason": "ok", "payload": payload}
