# LAN Transport Harness

Run the following command from the repository root after installing the self-contained Godot 4 Linux runtime:

```bash
GODOT_SILENCE_ROOT_WARNING=1 /home/ubuntu/tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://tests/lan_transport_harness.gd
```

The harness creates an **ENet server** and an **ENet client** on `127.0.0.1:18873`, polls both peers, and passes only after the client reports `CONNECTION_CONNECTED` and the server reports the client peer. It is a loopback/LAN wiring test. It does not test public Internet connectivity, NAT traversal, matchmaking, Steamworks, relay routing, port-forwarding, mobile exports, or anti-cheat.
