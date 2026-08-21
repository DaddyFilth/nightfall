class_name NativePreferenceAdapter
extends RefCounted

const Bridge = preload("res://scripts/integration/platform_preference_file_bridge.gd")
const ANDROID_SINGLETON := "NightfallAndroidPreferenceBridge"
const IOS_SINGLETON := "NightfallIOSPreferenceBridge"

static func expected_singleton() -> String:
	if OS.get_name() == "Android":
		return ANDROID_SINGLETON
	if OS.get_name() == "iOS":
		return IOS_SINGLETON
	return ""

static func availability() -> Dictionary:
	var singleton_name := expected_singleton()
	if singleton_name.is_empty():
		return {"available": false, "reason": "unsupported_platform"}
	if not Engine.has_singleton(singleton_name):
		return {"available": false, "reason": "plugin_missing", "singleton": singleton_name}
	return {"available": true, "reason": "ok", "singleton": singleton_name}

static func install_from_native_adapter() -> Dictionary:
	var status := availability()
	if not status["available"]:
		return {"installed": false, "reason": status["reason"]}
	var plugin: Object = Engine.get_singleton(status["singleton"])
	var raw: Variant = plugin.call("read_approved_payload")
	if not raw is String or raw.is_empty():
		return {"installed": false, "reason": "payload_missing"}
	var parser := JSON.new()
	if parser.parse(raw) != OK or not parser.data is Dictionary:
		return {"installed": false, "reason": "payload_json"}
	return Bridge.install_payload(parser.data)

