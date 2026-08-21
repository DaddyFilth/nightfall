extends RefCounted

const DISTRICTS := [
	{"id": "brasswake_dockyards", "title": "BRASSWAKE DOCKYARDS", "subtitle": "Wet berths, crane alleys, and boarded freighters.", "position": Vector3(0, 0.0, 7.0), "accent": Color("C7973A")},
	{"id": "sable_quarter", "title": "SABLE QUARTER", "subtitle": "Salt-black warehouses beneath a broken compass tower.", "position": Vector3(-7.0, 0.0, 1.5), "accent": Color("4A877A")},
	{"id": "cathedral_causeway", "title": "CATHEDRAL CAUSEWAY", "subtitle": "A brass-lit road toward the drowned bell nave.", "position": Vector3(7.0, 0.0, 0.5), "accent": Color("8D2634")},
	{"id": "cinder_locks", "title": "CINDER LOCKS", "subtitle": "Steam locks and ember pumps at the canal throat.", "position": Vector3(-5.5, 0.0, -8.0), "accent": Color("D96A3A")},
	{"id": "iron_foreshore", "title": "IRON FORESHORE", "subtitle": "Armored breakwater and a view of the eclipse sea.", "position": Vector3(5.5, 0.0, -8.0), "accent": Color("6D8A94")},
]

static func count() -> int:
	return DISTRICTS.size()

static func district(index: int) -> Dictionary:
	return (DISTRICTS[clampi(index, 0, DISTRICTS.size() - 1)] as Dictionary).duplicate(true)

static func district_for_id(id: String) -> Dictionary:
	for district_data in DISTRICTS:
		if str(district_data.get("id", "")) == id:
			return (district_data as Dictionary).duplicate(true)
	return district(0)
