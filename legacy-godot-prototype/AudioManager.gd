## AudioManager.gd  –  autoload singleton
## Generates procedural tones via AudioStreamGenerator so no audio asset files
## are required.  Exposes play_music(), stop_music(), play_sfx_tap(),
## play_sfx_milestone(), play_sfx_danger(), play_sfx_level_up().
extends Node

# ── constants ─────────────────────────────────────────────────────────────────
const SAMPLE_RATE   := 44100.0
const BUFFER_SIZE   := 512

# ── music state ───────────────────────────────────────────────────────────────
var _music_player:    AudioStreamPlayer
var _music_generator: AudioStreamGenerator
var _music_playback:  AudioStreamGeneratorPlayback
var _music_phase:     float = 0.0
var _music_pitch:     float = 1.0        # set from outside
var _music_active:    bool  = false

# Simple two-voice chord table (root + fifth, multiplied by pitch)
const BASE_FREQ := 110.0  # A2
const CHORD_RATIOS := [1.0, 1.5, 2.0, 2.5]   # root, fifth, octave, 12th

# ── sfx players ───────────────────────────────────────────────────────────────
var _sfx_players: Array = []
const SFX_POOL := 6

# ── lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_music_player()
	_build_sfx_pool()

func _build_music_player() -> void:
	_music_generator = AudioStreamGenerator.new()
	_music_generator.mix_rate  = SAMPLE_RATE
	_music_generator.buffer_length = 0.1

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = _music_generator
	_music_player.volume_db = -12.0
	add_child(_music_player)

func _build_sfx_pool() -> void:
	for i in SFX_POOL:
		var p := AudioStreamPlayer.new()
		p.volume_db = -6.0
		add_child(p)
		_sfx_players.append(p)

# ── public API ────────────────────────────────────────────────────────────────
func play_music(pitch: float = 1.0) -> void:
	_music_pitch  = pitch
	_music_active = true
	_music_phase  = 0.0
	_music_player.play()
	_music_playback = _music_player.get_stream_playback()

func stop_music() -> void:
	_music_active = false
	_music_player.stop()

func set_music_pitch(pitch: float) -> void:
	_music_pitch = pitch

## Tap SFX – short bright sine blip
func play_sfx_tap() -> void:
	_play_tone(440.0 * _music_pitch, 0.06, -14.0)

## Milestone SFX – rising arpeggio
func play_sfx_milestone() -> void:
	for i in 4:
		await get_tree().create_timer(i * 0.07).timeout
		_play_tone(BASE_FREQ * CHORD_RATIOS[i] * _music_pitch * 2.0, 0.12, -10.0)

## Danger SFX – low pulse
func play_sfx_danger() -> void:
	_play_tone(BASE_FREQ * 0.5 * _music_pitch, 0.18, -8.0)

## Level-up SFX – triumphant sweep
func play_sfx_level_up() -> void:
	var freqs := [261.63, 329.63, 392.0, 523.25, 659.25]
	for i in freqs.size():
		await get_tree().create_timer(i * 0.09).timeout
		_play_tone(freqs[i] * _music_pitch, 0.15, -8.0)

# ── internal ──────────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	if not _music_active or _music_playback == null:
		return
	_fill_music_buffer()

func _fill_music_buffer() -> void:
	var frames_available := _music_playback.get_frames_available()
	if frames_available <= 0:
		return

	var dt := 1.0 / SAMPLE_RATE
	for _i in frames_available:
		var t    := _music_phase
		var s    := 0.0
		# Soft pad: blend three harmonics at low amplitude
		s += 0.30 * sin(TAU * BASE_FREQ * _music_pitch * t)
		s += 0.15 * sin(TAU * BASE_FREQ * _music_pitch * 1.5 * t)
		s += 0.08 * sin(TAU * BASE_FREQ * _music_pitch * 2.0 * t)
		# Slow LFO tremolo
		s *= 0.80 + 0.20 * sin(TAU * 0.4 * t)
		_music_phase += dt
		_music_playback.push_frame(Vector2(s, s))

## Play a short sine burst on the next free SFX player.
func _play_tone(freq: float, duration: float, vol_db: float) -> void:
	# Build a tiny PCM buffer via AudioStreamWAV
	var sample_count := int(SAMPLE_RATE * duration)
	var data          := PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit mono

	for i in sample_count:
		var t     := float(i) / SAMPLE_RATE
		var env   := 1.0 - (float(i) / sample_count)          # linear decay
		var value := sin(TAU * freq * t) * env * 32767.0
		var s     := int(clamp(value, -32768, 32767))
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF

	var wav            := AudioStreamWAV.new()
	wav.format         = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate       = int(SAMPLE_RATE)
	wav.stereo         = false
	wav.data           = data

	# Find a free player
	for p in _sfx_players:
		if not p.playing:
			p.volume_db = vol_db
			p.stream    = wav
			p.play()
			return

	# All busy – use first one anyway
	var p: AudioStreamPlayer = _sfx_players[0]
	p.volume_db = vol_db
	p.stream    = wav
	p.play()
