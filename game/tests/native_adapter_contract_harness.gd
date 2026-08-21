extends SceneTree

const Adapter = preload("res://scripts/integration/native_preference_adapter.gd")
const Bridge = preload("res://scripts/integration/platform_preference_file_bridge.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var availability := Adapter.availability()
	_assert(not availability["available"] and availability["reason"] == "unsupported_platform", "headless_platform_boundary")
	var payload := {"schema": "nightfall.godot-preferences.v1", "preferences": {"sensitivity": 65, "reducedMotion": false, "highContrastReticle": false, "subtitles": true, "colorMarkers": true, "vibration": true, "audioCueSubtitles": true, "touchLayout": "right_handed", "touchPrimaryAction": "fire"}, "campaign": {"observatoryBranch": null}}
	var result := Bridge.install_payload(payload)
	_assert(result["installed"], "contract_payload_installs")
	print("NATIVE_ADAPTER_CONTRACT_PASS platform=headless adapter=bounded payload=validated")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		printerr("NATIVE_ADAPTER_CONTRACT_FAIL " + label)
		quit(1)
