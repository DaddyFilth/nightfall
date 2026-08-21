class_name ExpoPreferenceHandoff
extends RefCounted

const SCHEMA := "nightfall.godot-preferences.v1"
const HANDOFF_PATH := "user://nightfall/expo-preferences.v1.json"

static func validate(payload: Dictionary) -> Dictionary:
	if payload.get("schema", "") != SCHEMA:
		return {"valid": false, "reason": "schema"}
	var preferences: Variant = payload.get("preferences")
	var campaign: Variant = payload.get("campaign")
	if not preferences is Dictionary or not campaign is Dictionary:
		return {"valid": false, "reason": "shape"}
	var sensitivity: Variant = preferences.get("sensitivity")
	if not sensitivity is float and not sensitivity is int:
		return {"valid": false, "reason": "sensitivity"}
	if float(sensitivity) < 20.0 or float(sensitivity) > 100.0:
		return {"valid": false, "reason": "sensitivity_range"}
	var layout := String(preferences.get("touchLayout", ""))
	var primary_action := String(preferences.get("touchPrimaryAction", ""))
	if layout != "right_handed" and layout != "left_handed":
		return {"valid": false, "reason": "layout"}
	if primary_action != "fire" and primary_action != "veil" and primary_action != "dash":
		return {"valid": false, "reason": "primary_action"}
	var branch: Variant = campaign.get("observatoryBranch")
	if branch != null and branch != "last_platform" and branch != "static_trail":
		return {"valid": false, "reason": "branch"}
	return {"valid": true, "reason": "ok"}

static func apply_to_audio(audio: Object, payload: Dictionary) -> bool:
	var result := validate(payload)
	if not result["valid"]:
		return false
	var preferences: Dictionary = payload["preferences"]
	audio.set("subtitles_enabled", preferences.get("audioCueSubtitles", true))
	audio.set("vibration_enabled", preferences.get("vibration", true))
	return true

static func observatory_branch(payload: Dictionary) -> String:
	var result := validate(payload)
	if not result["valid"]:
		return "last_platform"
	var branch: Variant = payload["campaign"].get("observatoryBranch")
	return "last_platform" if branch == null else String(branch)
