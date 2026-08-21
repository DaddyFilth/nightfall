extends SceneTree

const NightfallAudio = preload("res://scripts/presentation/nightfall_audio.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var audio := NightfallAudio.new()
	var captions: Array[String] = []
	var vibrations: Array[String] = []
	audio.subtitle_requested.connect(func(subtitle: String) -> void: captions.append(subtitle))
	audio.vibration_requested.connect(func(cue_id: String) -> void: vibrations.append(cue_id))
	root.add_child(audio)
	await process_frame
	for cue_id in ["projectile_fire", "impact_target", "enemy_attack", "enemy_hit", "enemy_dissolve", "cinematic_transition", "wheel_lock_reload"]:
		var profile: Dictionary = audio.cue_profile(cue_id)
		_assert(profile["frequency"] > 0.0 and profile["duration"] > 0.0, "profile_" + cue_id)
		audio.play_cue(cue_id)
		_assert(audio.last_cue == cue_id, "play_" + cue_id)
	_assert(captions.size() == 7 and vibrations.size() == 7 and captions.has("WHEEL-LOCK RELOADING"), "accessible_cue_signals")
	audio.subtitles_enabled = false
	audio.vibration_enabled = false
	audio.play_cue("projectile_fire")
	_assert(captions.size() == 7 and vibrations.size() == 7, "accessible_toggles")
	print("AUDIO_HARNESS_PASS cues=7 source=procedural_local")
	audio.queue_free()
	await process_frame
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("AUDIO_HARNESS_FAIL " + label)
		quit(1)
