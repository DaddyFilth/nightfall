class_name EnetLanTransport
extends NetworkTransport

## LAN and editor adapter. Never present this adapter as internet P2P.
var peer := ENetMultiplayerPeer.new()
var active_port := 0

func _ready() -> void:
	multiplayer.peer_connected.connect(func(id: int): peer_connected.emit(id))
	multiplayer.peer_disconnected.connect(func(id: int): peer_disconnected.emit(id))
	multiplayer.connection_failed.connect(func(): transport_failed.emit("connection_failed"))

func host(port: int, max_players: int) -> Error:
	var result := peer.create_server(port, max_players)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		active_port = port
	return result

func join(address: String, port: int) -> Error:
	var result := peer.create_client(address, port)
	if result == OK:
		multiplayer.multiplayer_peer = peer
	return result

func close() -> void:
	peer.close()
	active_port = 0
	super.close()
