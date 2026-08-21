class_name NightfallProjectile
extends Node3D

const SOLID_LAYER := 1
const TARGET_LAYER := 8
@export var damage := 25
@export var range := 18.0
var direction := Vector3.FORWARD
var travelled := 0.0
var resolved := false

func fire(origin: Vector3, aim_direction: Vector3) -> void:
	global_position = origin
	direction = aim_direction.normalized()

func resolve_segment(distance: float) -> Dictionary:
	if resolved or not is_inside_tree() or direction.length() < 0.5:
		return {"resolved": resolved, "kind": "invalid"}
	var end: Vector3 = global_position + direction * min(distance, range - travelled)
	var query := PhysicsRayQueryParameters3D.create(global_position, end, SOLID_LAYER | TARGET_LAYER, [])
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = end
		travelled += global_position.distance_to(end)
		if travelled >= range:
			resolved = true
			return {"resolved": true, "kind": "range"}
		return {"resolved": false, "kind": "none"}
	resolved = true
	global_position = hit["position"]
	var collider: Object = hit["collider"]
	if collider.has_meta("nightfall_damage_target"):
		var target: Object = collider.get_meta("nightfall_damage_target")
		if target.has_method("take_projectile_hit"):
			var result: Dictionary = target.take_projectile_hit(damage, global_position)
			return {"resolved": true, "kind": "target", "result": result}
	return {"resolved": true, "kind": "solid"}
