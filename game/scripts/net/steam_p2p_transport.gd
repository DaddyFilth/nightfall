class_name SteamP2PTransport
extends NetworkTransport

## Integration seam for a GodotSteam/Steam Networking Sockets production adapter.
## This class deliberately fails closed until the reviewed native extension and Steam App ID are configured.
func host(_port: int, _max_players: int) -> Error:
	transport_failed.emit("steam_p2p_adapter_not_installed")
	return ERR_UNAVAILABLE

func join(_address: String, _port: int) -> Error:
	transport_failed.emit("steam_p2p_adapter_not_installed")
	return ERR_UNAVAILABLE

