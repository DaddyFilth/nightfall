extends Node

const LocalModeSimulator = preload("res://scripts/rules/local_mode_simulator.gd")

## Temporary match authority. It validates client intents and owns score, health, deaths, respawn, and timer state.
const MAX_INPUTS_PER_SECOND := 30
const MAX_ABILITY_RANGE := 18.0
const RESPAWN_SECONDS := 3.0

var mode_id := "free_for_all"
var max_players := 8
var score_limit := 30
var match_duration := 480.0
var elapsed := 0.0
var active := false
var player_state: Dictionary = {}
var rules := LocalModeSimulator.new()

func configure_rules(next_mode_id: String, next_max_players: int, next_score_limit: int, next_duration: float) -> void:
	mode_id = next_mode_id
	max_players = clampi(next_max_players, 2, 8)
	score_limit = max(next_score_limit, 1)
	match_duration = max(next_duration, 60.0)
	rules.configure(mode_id, score_limit)

func begin_match() -> void:
	elapsed = 0.0
	active = true
	match_state.rpc({"phase": "active", "mode": mode_id, "score_limit": score_limit, "rules": rules.snapshot()})

func _physics_process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	if elapsed >= match_duration:
		finish_match("time_expired")

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func submit_input(sequence: int, movement: Vector2, aim: Vector2, client_time: float) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if not _accept_input(sender, sequence, movement, aim, client_time):
		return
	player_state[sender]["movement"] = movement.limit_length(1.0)
	player_state[sender]["aim"] = aim.normalized()

@rpc("any_peer", "call_remote", "reliable", 0)
func request_ability(ability_id: String, origin: Vector3, target: Vector3, sequence: int) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if not active or not _is_ability_valid(sender, ability_id, origin, target, sequence):
		return
	player_state[sender]["last_ability_sequence"] = sequence
	ability_confirmed.rpc(sender, ability_id, target)

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func snapshot(_payload: Dictionary) -> void:
	pass

@rpc("authority", "call_remote", "reliable", 0)
func match_state(_payload: Dictionary) -> void:
	pass

@rpc("authority", "call_remote", "reliable", 0)
func ability_confirmed(_peer_id: int, _ability_id: String, _target: Vector3) -> void:
	pass

func register_player(peer_id: int, requested_team: String = "auto") -> bool:
	if player_state.size() >= max_players:
		return false
	if not rules.register_player(peer_id, requested_team):
		return false
	player_state[peer_id] = {"health": 100, "score": 0, "deaths": 0, "team": rules.player_team(peer_id), "last_sequence": -1, "last_ability_sequence": -1, "last_input_at": 0.0}
	return true

func resolve_damage(attacker_id: int, victim_id: int, amount: int) -> void:
	if not active or not player_state.has(attacker_id) or not player_state.has(victim_id):
		return
	var safe_damage := clampi(amount, 0, 100)
	player_state[victim_id]["health"] -= safe_damage
	if player_state[victim_id]["health"] <= 0:
		player_state[victim_id]["deaths"] += 1
		var outcome: Dictionary = rules.record_elimination(attacker_id, victim_id)
		if outcome["scored"]:
			player_state[attacker_id]["score"] = rules.player_score(attacker_id)
		if rules.complete:
			finish_match("score_limit")

func try_pickup_relic(player_id: int, relic_team: String) -> bool:
	return active and rules.pickup_relic(player_id, relic_team)

func try_capture_relic(player_id: int, sanctuary_team: String) -> bool:
	if not active or not rules.capture_relic(player_id, sanctuary_team):
		return false
	player_state[player_id]["score"] = rules.player_score(player_id)
	if rules.complete:
		finish_match("capture_limit")
	return true

func finish_match(reason: String) -> void:
	if not active:
		return
	active = false
	match_state.rpc({"phase": "results", "reason": reason, "players": player_state, "rules": rules.snapshot()})

func _accept_input(sender: int, sequence: int, movement: Vector2, aim: Vector2, client_time: float) -> bool:
	if not active or not player_state.has(sender):
		return false
	var state: Dictionary = player_state[sender]
	if sequence <= state["last_sequence"] or movement.length() > 1.05 or aim.length() > 1.05:
		return false
	var now := Time.get_ticks_msec() / 1000.0
	if now - state["last_input_at"] < 1.0 / MAX_INPUTS_PER_SECOND:
		return false
	if abs(now - client_time) > 5.0:
		return false
	state["last_sequence"] = sequence
	state["last_input_at"] = now
	player_state[sender] = state
	return true

func _is_ability_valid(sender: int, ability_id: String, origin: Vector3, target: Vector3, sequence: int) -> bool:
	if not player_state.has(sender) or sequence <= player_state[sender]["last_ability_sequence"]:
		return false
	if ability_id.is_empty() or origin.distance_to(target) > MAX_ABILITY_RANGE:
		return false
	return true
