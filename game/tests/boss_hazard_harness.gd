extends SceneTree

const CampaignBossHazard = preload("res://scripts/gameplay/campaign_boss_hazard.gd")

class DamageProbe extends Node3D:
	var hits := 0
	func take_enemy_hit(_damage: int, _source: Vector3, _knockback: float) -> Dictionary:
		hits += 1
		return {"accepted": true}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var probe := DamageProbe.new()
	root.add_child(probe)
	var hazard := CampaignBossHazard.new()
	hazard.configure({"name": "TEST DECKBREAK", "mode": "deckbreak", "count": 3, "damage": 12, "interval": 4.0, "accent": Color("C7973A")})
	hazard.track_player(probe)
	root.add_child(hazard)
	await process_frame
	hazard.set_active(true)
	hazard.trigger_hazard()
	var telegraphed := hazard.windup_remaining > 0.0 and hazard.get_node_or_null("BossHazardLabel") != null
	if hazard.marker_positions.size() > 0:
		probe.global_position = hazard.marker_positions[0]
	hazard.force_resolve()
	if telegraphed and hazard.markers.size() == 3 and probe.hits == 1:
		print("BOSS_HAZARD_PASS telegraph=visible damage=local zones=3")
		quit(0)
		return
	printerr("BOSS_HAZARD_FAIL telegraph=%s markers=%s hits=%s" % [telegraphed, hazard.markers.size(), probe.hits])
	quit(1)
