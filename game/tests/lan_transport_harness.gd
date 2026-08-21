extends SceneTree

## Executes against the native Godot runtime. It validates ENet listener creation, loopback joining,
## and host peer discovery without claiming an Internet or NAT traversal test.
const TEST_PORT := 18873
const MAX_FRAMES := 300

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var host := ENetMultiplayerPeer.new()
	var host_result := host.create_server(TEST_PORT, 2)
	if host_result != OK:
		printerr("LAN_HARNESS_FAIL host_create=" + error_string(host_result))
		quit(1)
		return

	var client := ENetMultiplayerPeer.new()
	var client_result := client.create_client("127.0.0.1", TEST_PORT)
	if client_result != OK:
		host.close()
		printerr("LAN_HARNESS_FAIL client_create=" + error_string(client_result))
		quit(1)
		return

	for frame in range(MAX_FRAMES):
		host.poll()
		client.poll()
		var host_has_client: bool = host.get_host().get_peers().size() == 1
		var client_connected: bool = client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
		if host_has_client and client_connected:
			print("LAN_HARNESS_PASS protocol=ENet transport=loopback port=" + str(TEST_PORT) + " frames=" + str(frame))
			client.close()
			host.close()
			quit(0)
			return
		await process_frame

	client.close()
	host.close()
	printerr("LAN_HARNESS_FAIL handshake_timeout")
	quit(1)
