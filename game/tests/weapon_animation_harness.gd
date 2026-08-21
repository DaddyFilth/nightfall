extends SceneTree

const NightfallPlayer = preload("res://scripts/gameplay/nightfall_player.gd")
const HollowedActor = preload("res://scripts/presentation/hollowed_actor.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var player := NightfallPlayer.new()
	root.add_child(player)
	await process_frame
	var started: Array[String] = []
	var finished: Array[String] = []
	player.weapon_animation_started.connect(func(weapon_id: String) -> void: started.append(weapon_id))
	player.weapon_animation_finished.connect(func(weapon_id: String) -> void: finished.append(weapon_id))
	player._set_touch_fire_held(true)
	player._physics_process(0.016)
	player._update_weapon_animations(0.16)
	var ads_requested := player.is_aiming_down_sights()
	var ads_fov := player.get_fps_camera().fov < 70.0
	var ads_weapon := player.wheel_lock_rig.position.x < NightfallPlayer.WHEEL_LOCK_REST_POSITION.x - 0.1
	var ads_visible := ads_requested and ads_fov and ads_weapon
	var first_fire_accepted := player.fire_wheel_lock()
	var second_fire_blocked := not player.fire_wheel_lock()
	player._update_weapon_animations(0.12)
	var recoil_visible := player.wheel_lock_rig.position.z > -0.72
	player._update_weapon_animations(0.2)
	player._update_weapon_animations(0.3)
	player._update_weapon_animations(0.3)
	var reload_finished := not player.is_reloading() and absf(player.wheel_lock_rig.rotation_degrees.z) < 0.01
	player.begin_cutlass_swing()
	player._update_weapon_animations(0.10)
	var swing_visible := player.cutlass_rig.rotation_degrees.z > -18.0
	player._update_weapon_animations(0.4)
	var hollowed := HollowedActor.new()
	root.add_child(hollowed)
	await process_frame
	hollowed._set_state(HollowedActor.AnimationState.ATTACK)
	hollowed._process(0.32)
	var privateer_swing_visible := hollowed.cutlass.rotation_degrees.z < 0.0
	var privateer_telegraph_visible := hollowed.attack_beacon.visible and hollowed.attack_beacon.scale.x > 1.1
	if started == ["wheel_lock", "wheel_lock_reload", "cutlass"] and finished == ["wheel_lock", "wheel_lock_reload", "cutlass"] and first_fire_accepted and second_fire_blocked and ads_visible and recoil_visible and reload_finished and swing_visible and privateer_swing_visible and privateer_telegraph_visible:
		print("WEAPON_ANIMATION_PASS wheel_lock=ads,recoil,reload cutlass privateer=attack_beacon")
		quit(0)
		return
	printerr("WEAPON_ANIMATION_FAIL started=%s finished=%s accepted=%s blocked=%s ads=%s requested=%s fov=%s weapon=%s recoil=%s reload=%s swing=%s privateer=%s telegraph=%s" % [started, finished, first_fire_accepted, second_fire_blocked, ads_visible, ads_requested, ads_fov, ads_weapon, recoil_visible, reload_finished, swing_visible, privateer_swing_visible, privateer_telegraph_visible])
	quit(1)
