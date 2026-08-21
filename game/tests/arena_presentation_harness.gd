extends SceneTree

const ArenaScene = preload("res://scenes/arena_showcase.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var arena := ArenaScene.instantiate()
	root.add_child(arena)
	await process_frame
	var floor_exists := arena.get_node_or_null("ArenaFloor") != null
	var backdrop := arena.get_node_or_null("BundledDockyardBackdrop/BundledDockyardArtwork") as MeshInstance3D
	var backdrop_material := backdrop.material_override as StandardMaterial3D if backdrop != null else null
	var bundled_art_visible := backdrop != null and backdrop.visible and backdrop.mesh != null and backdrop_material != null and backdrop_material.albedo_texture != null
	var initial_backdrop_y := backdrop.position.y if backdrop != null else 0.0
	var engine_exists := arena.get_node_or_null("EclipseEngine") != null
	var dockyard_exists := arena.find_child("GalleonMast_*", true, false) != null
	var sail_exists := arena.find_child("BlackSail_*", true, false) != null
	var sail := arena.find_child("BlackSail_*", true, false) as MeshInstance3D
	var initial_sail_roll := sail.rotation_degrees.z if sail != null else 0.0
	var fog_exists := arena.get_node_or_null("BrasswakeAtmosphereFX/SeaFogBank_0") != null
	var spray_exists := arena.get_node_or_null("BrasswakeAtmosphereFX/SeaSpray_0") != null
	var tactical_cover_exists := arena.get_node_or_null("CargoCrate_0") != null
	var wet_detail_exists := arena.find_child("RainPuddle_*", true, false) != null
	var wet_reflection := arena.find_child("RainPuddle_*", true, false) as MeshInstance3D
	var initial_reflection_scale := wet_reflection.scale.x if wet_reflection != null else 0.0
	var key_light_exists := arena.get_node_or_null("BrasswakeKeyLight") != null
	var rim_light_exists := arena.get_node_or_null("BrasswakeRimLight") != null
	var eclipse_light_exists := arena.get_node_or_null("EclipseCoreLight") != null
	var sparks_exist := arena.get_node_or_null("PremiumDepthFX/AtmosphericSparks_0") != null
	var material_depth_exists := arena.get_node_or_null("CargoFacePlate_0") != null and arena.get_node_or_null("DeckSeam_-14") != null
	var tactical_camera := arena.get_node_or_null("PresentationCamera") as Camera3D
	var camera_is_grounded := tactical_camera != null and tactical_camera.fov <= 60.0
	var captain_visual_exists := arena.get_node_or_null("NightfallPlayer/BloodwakeCaptainVisual") != null
	var player := arena.get_node_or_null("NightfallPlayer")
	var viewmodel := player.get_node_or_null("FirstPersonPitchPivot/FirstPersonCamera/BloodwakeViewmodel") as Node3D if player != null else null
	var viewmodel_visible: bool = viewmodel != null and viewmodel.visible
	var enemies := get_nodes_in_group("nightfall_enemy")
	var privateer_visual_exists := enemies.size() > 0 and enemies[0].get_node_or_null("TexturedHollowedMesh/PrivateerTricornBrim") != null
	await create_timer(0.24).timeout
	var sail_animated := sail != null and absf(sail.rotation_degrees.z - initial_sail_roll) > 0.001
	var backdrop_animated := backdrop != null and absf(backdrop.position.y - initial_backdrop_y) > 0.0001
	var wet_reflection_animated := wet_reflection != null and absf(wet_reflection.scale.x - initial_reflection_scale) > 0.0001
	if floor_exists and bundled_art_visible and backdrop_animated and engine_exists and dockyard_exists and sail_exists and sail_animated and fog_exists and spray_exists and tactical_cover_exists and wet_detail_exists and wet_reflection_animated and key_light_exists and rim_light_exists and eclipse_light_exists and sparks_exist and material_depth_exists and camera_is_grounded and captain_visual_exists and viewmodel_visible and privateer_visual_exists and enemies.size() == 4:
		print("ARENA_PRESENTATION_PASS geometry=brasswake artwork=bundled lighting=premium animation=sail,backdrop,wet-deck,fog,spray,sparks enemies=" + str(enemies.size()) + " captain=pirate_vampire")
		quit(0)
		return
	printerr("ARENA_PRESENTATION_FAIL floor=%s artwork=%s backdrop_animated=%s engine=%s dockyard=%s sail=%s sail_animated=%s fog=%s spray=%s cover=%s wet=%s wet_animated=%s key=%s rim=%s eclipse=%s sparks=%s material=%s camera=%s captain=%s viewmodel=%s privateer=%s enemies=%s" % [floor_exists, bundled_art_visible, backdrop_animated, engine_exists, dockyard_exists, sail_exists, sail_animated, fog_exists, spray_exists, tactical_cover_exists, wet_detail_exists, wet_reflection_animated, key_light_exists, rim_light_exists, eclipse_light_exists, sparks_exist, material_depth_exists, camera_is_grounded, captain_visual_exists, viewmodel_visible, privateer_visual_exists, enemies.size()])
	quit(1)
