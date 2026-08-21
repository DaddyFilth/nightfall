#pragma once

#include "core/object/object.h"

class NightfallIOSPreferenceBridge : public Object {
	GDCLASS(NightfallIOSPreferenceBridge, Object);

protected:
	static void _bind_methods();

public:
	String read_approved_payload();
};
