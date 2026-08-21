extends Node

## Explicit bootstrap: use ENet for LAN development only. Internet P2P requires a reviewed transport adapter.
func _ready() -> void:
	var authority := get_node_or_null("/root/MatchHost")
	if authority:
		authority.configure_rules("free_for_all", 8, 30, 480.0)
