extends RefCounted

const PROGRESS_PATH := "user://nightfall/open-world.v1.cfg"

static func visited_districts() -> PackedStringArray:
	var config := ConfigFile.new()
	if config.load(PROGRESS_PATH) != OK:
		return PackedStringArray()
	var raw: Variant = config.get_value("exploration", "districts", PackedStringArray())
	var result := PackedStringArray()
	for district_id in raw:
		var safe_id := str(district_id)
		if not safe_id.is_empty() and not result.has(safe_id):
			result.append(safe_id)
	return result

static func record_district_visit(district_id: String) -> PackedStringArray:
	var visits := visited_districts()
	if not visits.has(district_id):
		visits.append(district_id)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://nightfall"))
	var config := ConfigFile.new()
	config.set_value("exploration", "districts", visits)
	config.save(PROGRESS_PATH)
	return visits
