extends SceneTree

const Handoff = preload("res://scripts/integration/expo_preference_handoff.gd")
const NightfallAudio = preload("res://scripts/presentation/nightfall_audio.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var payload := {"schema": "nightfall.godot-preferences.v1", "preferences": {"sensitivity": 80, "reducedMotion": false, "highContrastReticle": true, "subtitles": true, "colorMarkers": true, "vibration": false, "audioCueSubtitles": false, "touchLayout": "left_handed", "touchPrimaryAction": "dash"}, "campaign": {"observatoryBranch": "static_trail"}}
	_assert(Handoff.validate(payload)["valid"], "valid_payload")
	_assert(Handoff.observatory_branch(payload) == "static_trail", "branch")
	var audio := NightfallAudio.new()
	root.add_child(audio)
	_assert(Handoff.apply_to_audio(audio, payload), "apply")
	_assert(not audio.subtitles_enabled and not audio.vibration_enabled, "audio_flags")
	var invalid := payload.duplicate(true)
	invalid["preferences"]["sensitivity"] = 101
	_assert(not Handoff.validate(invalid)["valid"], "invalid_payload")
	print("PREFERENCE_HANDOFF_PASS schema=v1 branch=static_trail preferences=applied")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("PREFERENCE_HANDOFF_FAIL " + label)
		quit(1)
