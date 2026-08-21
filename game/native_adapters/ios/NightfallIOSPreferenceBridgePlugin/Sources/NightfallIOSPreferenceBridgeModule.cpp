#include "NightfallIOSPreferenceBridgeModule.h"
#include "NightfallIOSPreferenceBridge.h"

#include "core/config/engine.h"
#include "core/os/memory.h"

static NightfallIOSPreferenceBridge *nightfall_preference_bridge = nullptr;

void register_nightfall_ios_preference_bridge_types() {
	if (nightfall_preference_bridge != nullptr) return;
	nightfall_preference_bridge = memnew(NightfallIOSPreferenceBridge);
	Engine::get_singleton()->add_singleton(Engine::Singleton("NightfallIOSPreferenceBridge", nightfall_preference_bridge));
}

void unregister_nightfall_ios_preference_bridge_types() {
	if (nightfall_preference_bridge != nullptr) {
		memdelete(nightfall_preference_bridge);
		nightfall_preference_bridge = nullptr;
	}
}
