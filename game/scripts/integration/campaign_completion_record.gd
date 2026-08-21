class_name CampaignCompletionRecord
extends RefCounted

const SCHEMA := "blood-brass.campaign-completion.v1"
const RECORD_PATH := "user://nightfall/export/campaign-completion.v1.json"

static func record_victory(mission_id: int, mission_title: String, defeated_through: int) -> Dictionary:
	var payload := build_payload(mission_id, mission_title, defeated_through)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall/export"))
	var file := FileAccess.open(RECORD_PATH, FileAccess.WRITE)
	if file == null:
		return {"written": false, "reason": "unwritable", "payload": payload}
	file.store_string(JSON.stringify(payload))
	file.flush()
	file.close()
	return {"written": true, "reason": "ok", "payload": payload, "path": RECORD_PATH}

static func build_payload(mission_id: int, mission_title: String, defeated_through: int) -> Dictionary:
	return {
		"schema": SCHEMA,
		"completedMission": clampi(mission_id, 1, 10),
		"defeatedThrough": clampi(defeated_through, 0, 10),
		"completedTitle": mission_title,
		"recordedAtUnix": int(Time.get_unix_time_from_system())
	}

static func validate(payload: Dictionary) -> Dictionary:
	if payload.get("schema", "") != SCHEMA:
		return {"valid": false, "reason": "schema"}
	var completed_mission: Variant = payload.get("completedMission", 0)
	var defeated_through: Variant = payload.get("defeatedThrough", 0)
	if not completed_mission is int or not defeated_through is int:
		return {"valid": false, "reason": "types"}
	if int(completed_mission) < 1 or int(completed_mission) > 10 or int(defeated_through) < int(completed_mission) or int(defeated_through) > 10:
		return {"valid": false, "reason": "range"}
	if str(payload.get("completedTitle", "")).is_empty():
		return {"valid": false, "reason": "title"}
	return {"valid": true, "reason": "ok"}
