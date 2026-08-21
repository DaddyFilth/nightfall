extends SceneTree

const Hollowed = preload("res://scripts/presentation/hollowed_actor.gd")
const Conductor = preload("res://scripts/gameplay/observatory_conductor.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	# These calls simulate editor/startup ordering where visual children are not ready yet.
	var unready_privateer := Hollowed.new()
	unready_privateer._process(0.016)
	var unready_admiral := Conductor.new()
	unready_admiral._physics_process(0.016)
	unready_admiral._sync_combat_nodes()
	unready_privateer.free()
	unready_admiral.free()
	print("SCENE_DEPENDENCY_GUARD_PASS unready_visuals=guarded nil_position=prevented")
	quit(0)
