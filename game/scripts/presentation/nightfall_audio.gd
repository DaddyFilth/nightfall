class_name NightfallAudio
extends Node

signal cue_played(cue_id: String)
signal subtitle_requested(subtitle: String)
signal vibration_requested(cue_id: String)
@export var subtitles_enabled := true
@export var vibration_enabled := true
var player: AudioStreamPlayer
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var last_cue := ""

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.35
	player = AudioStreamPlayer.new()
	player.stream = generator
	player.volume_db = -14.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback()

func play_cue(cue_id: String) -> void:
	last_cue = cue_id
	cue_played.emit(cue_id)
	if subtitles_enabled:
		subtitle_requested.emit(cue_subtitle(cue_id))
	if vibration_enabled:
		vibration_requested.emit(cue_id)
	if not playback:
		return
	var profile := cue_profile(cue_id)
	var frequency: float = profile["frequency"]
	var duration: float = profile["duration"]
	var gain: float = profile["gain"]
	var frames := int(generator.mix_rate * duration)
	for frame in frames:
		var progress := float(frame) / float(max(frames, 1))
		var envelope := (1.0 - progress) * gain
		var sample := sin(TAU * frequency * float(frame) / generator.mix_rate) * envelope
		playback.push_frame(Vector2(sample, sample))

func cue_profile(cue_id: String) -> Dictionary:
	match cue_id:
		"projectile_fire": return {"frequency": 220.0, "duration": 0.09, "gain": 0.42}
		"impact_target": return {"frequency": 78.0, "duration": 0.14, "gain": 0.5}
		"impact_solid": return {"frequency": 126.0, "duration": 0.08, "gain": 0.3}
		"enemy_attack": return {"frequency": 164.0, "duration": 0.16, "gain": 0.35}
		"enemy_hit": return {"frequency": 290.0, "duration": 0.10, "gain": 0.3}
		"enemy_dissolve": return {"frequency": 92.0, "duration": 0.32, "gain": 0.45}
		"cinematic_transition": return {"frequency": 246.0, "duration": 0.26, "gain": 0.22}
		"wheel_lock_fire": return {"frequency": 108.0, "duration": 0.12, "gain": 0.38}
		"wheel_lock_reload": return {"frequency": 174.0, "duration": 0.18, "gain": 0.28}
		"cutlass_swing": return {"frequency": 312.0, "duration": 0.15, "gain": 0.26}
		_: return {"frequency": 110.0, "duration": 0.06, "gain": 0.2}

func cue_subtitle(cue_id: String) -> String:
	match cue_id:
		"projectile_fire": return "THORNCOIL FIRED"
		"impact_target": return "HIT CONFIRMED"
		"impact_solid": return "SHOT BLOCKED"
		"enemy_attack": return "HOLLOWED STRIKES"
		"enemy_hit": return "HOLLOWED STAGGERS"
		"enemy_dissolve": return "THREAT DISPERSED"
		"cinematic_transition": return "ARCHIVE TRANSITION"
		"wheel_lock_fire": return "WHEEL-LOCK FIRED"
		"wheel_lock_reload": return "WHEEL-LOCK RELOADING"
		"cutlass_swing": return "CUTLASS SWINGS"
		_: return "AUDIO CUE"
