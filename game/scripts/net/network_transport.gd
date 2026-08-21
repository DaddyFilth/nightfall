class_name NetworkTransport
extends Node

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal transport_failed(reason: String)

func host(_port: int, _max_players: int) -> Error:
	push_error("NetworkTransport.host must be implemented by an adapter")
	return ERR_UNAVAILABLE

func join(_address: String, _port: int) -> Error:
	push_error("NetworkTransport.join must be implemented by an adapter")
	return ERR_UNAVAILABLE

func close() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

