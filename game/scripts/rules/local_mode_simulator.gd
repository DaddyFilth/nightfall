class_name LocalModeSimulator
extends RefCounted

const FREE_FOR_ALL := "free_for_all"
const TEAM_DEATHMATCH := "team_deathmatch"
const CAPTURE_THE_FLAG := "capture_the_flag"
const TEAMS := ["crimson", "violet"]

var mode_id: String = FREE_FOR_ALL
var score_limit: int = 30
var complete: bool = false
var player_state: Dictionary = {}
var team_scores: Dictionary = {"crimson": 0, "violet": 0}
var relic_carrier: Dictionary = {"crimson": -1, "violet": -1}

func configure(next_mode_id: String, next_score_limit: int) -> bool:
	if next_mode_id != FREE_FOR_ALL and next_mode_id != TEAM_DEATHMATCH and next_mode_id != CAPTURE_THE_FLAG:
		return false
	mode_id = next_mode_id
	score_limit = max(next_score_limit, 1)
	complete = false
	player_state.clear()
	team_scores = {"crimson": 0, "violet": 0}
	relic_carrier = {"crimson": -1, "violet": -1}
	return true

func register_player(player_id: int, requested_team: String = "auto") -> bool:
	if player_state.has(player_id):
		return false
	var team := "none"
	if mode_id != FREE_FOR_ALL:
		team = _resolve_team(requested_team)
	player_state[player_id] = {"team": team, "score": 0, "kills": 0, "deaths": 0, "carrying": ""}
	return true

func record_elimination(attacker_id: int, victim_id: int) -> Dictionary:
	if complete or attacker_id == victim_id or not player_state.has(attacker_id) or not player_state.has(victim_id):
		return {"accepted": false, "scored": false}
	var attacker: Dictionary = player_state[attacker_id]
	var victim: Dictionary = player_state[victim_id]
	if mode_id != FREE_FOR_ALL and attacker["team"] == victim["team"]:
		return {"accepted": false, "scored": false}
	attacker["kills"] += 1
	attacker["score"] += 1
	victim["deaths"] += 1
	player_state[attacker_id] = attacker
	player_state[victim_id] = victim
	if mode_id == FREE_FOR_ALL:
		if attacker["score"] >= score_limit:
			complete = true
	else:
		team_scores[attacker["team"]] += 1
		if team_scores[attacker["team"]] >= score_limit:
			complete = true
	return {"accepted": true, "scored": true, "team": attacker["team"], "complete": complete}

func pickup_relic(player_id: int, relic_team: String) -> bool:
	if mode_id != CAPTURE_THE_FLAG or complete or not player_state.has(player_id) or not TEAMS.has(relic_team):
		return false
	var player: Dictionary = player_state[player_id]
	if player["team"] == relic_team or player["carrying"] != "" or relic_carrier[relic_team] != -1:
		return false
	relic_carrier[relic_team] = player_id
	player["carrying"] = relic_team
	player_state[player_id] = player
	return true

func return_relic(relic_team: String) -> bool:
	if mode_id != CAPTURE_THE_FLAG or not TEAMS.has(relic_team):
		return false
	var carrier: int = relic_carrier[relic_team]
	if carrier != -1 and player_state.has(carrier):
		var carrier_state: Dictionary = player_state[carrier]
		carrier_state["carrying"] = ""
		player_state[carrier] = carrier_state
	relic_carrier[relic_team] = -1
	return true

func capture_relic(player_id: int, sanctuary_team: String) -> bool:
	if mode_id != CAPTURE_THE_FLAG or complete or not player_state.has(player_id) or not TEAMS.has(sanctuary_team):
		return false
	var player: Dictionary = player_state[player_id]
	var carried_relic: String = player["carrying"]
	if player["team"] != sanctuary_team or carried_relic == "" or carried_relic == sanctuary_team:
		return false
	team_scores[sanctuary_team] += 1
	player["score"] += 1
	player["carrying"] = ""
	player_state[player_id] = player
	relic_carrier[carried_relic] = -1
	if team_scores[sanctuary_team] >= score_limit:
		complete = true
	return true

func player_team(player_id: int) -> String:
	if not player_state.has(player_id):
		return "none"
	return player_state[player_id]["team"]

func player_score(player_id: int) -> int:
	if not player_state.has(player_id):
		return 0
	return player_state[player_id]["score"]

func snapshot() -> Dictionary:
	return {"mode": mode_id, "complete": complete, "score_limit": score_limit, "teams": team_scores.duplicate(true), "relic_carrier": relic_carrier.duplicate(true), "players": player_state.duplicate(true)}

func _resolve_team(requested_team: String) -> String:
	if TEAMS.has(requested_team):
		return requested_team
	var crimson_count := 0
	var violet_count := 0
	for state in player_state.values():
		if state["team"] == "crimson":
			crimson_count += 1
		elif state["team"] == "violet":
			violet_count += 1
	return "crimson" if crimson_count <= violet_count else "violet"

