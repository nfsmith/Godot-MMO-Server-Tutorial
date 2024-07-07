extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909

var token
var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

signal update_stats(stats)
signal verify_success
signal verify_fail
signal spawn_player(player_id, spawn_position)
signal despawn_player(player_id)
signal update_world_state(world_states)


func _physics_process(delta): #0.01667
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func ConnectToServer():
	var error = network.create_client(ip, port)
	if error:
		print(error)
		return error
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)

func _OnConnectionFailed():
	print("Failed to Connect")
	
func _OnConnectionSucceeded():
	print("Successfully connected to game server")
	FetchServerTime.rpc_id(1,Time.get_unix_time_from_system())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(DetermineLatency)
	self.add_child(timer)

@rpc("any_peer")
func FetchServerTime(client_time):
	pass

@rpc
func ReturnServerTime(server_time, client_time):
	latency = (Time.get_unix_time_from_system() - client_time) / 2
	client_clock = server_time + latency

@rpc("any_peer")
func DetermineLatency():
	DetermineLatency.rpc_id(1, Time.get_unix_time_from_system())

@rpc
func ReturnLatency(client_time):
	latency_array.append((Time.get_unix_time_from_system() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove_at(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()

@rpc("any_peer")
func FetchToken():
	rpc_id(1, "ReturnToken", token)

@rpc("any_peer")
func ReturnToken(token):
	pass

@rpc("any_peer")
func ReturnTokenVerificationResults(result):
	if result == true:
		verify_success.emit()
		print("Successful token verification")
	else:
		print("Login failed, please try again")
		verify_fail.emit()

func SendPlayerState(player_state):
	ReceivePlayerState.rpc_id(1, player_state)

@rpc("any_peer","unreliable")
func ReceivePlayerState(player_state):
	pass

@rpc
func ReceiveWorldState(world_state):
	update_world_state.emit(world_state)


@rpc
func SpawnNewPlayer(player_id, spawn_position):
	spawn_player.emit(player_id, spawn_position)

@rpc
func DespawnPlayer(player_id):
	despawn_player.emit(player_id)


func CallFetchSkillDamage(skill_name, requester):
	if not multiplayer.is_server():
		rpc_id(1, "FetchSkillDamage", skill_name, requester)
	

@rpc("any_peer")
func FetchSkillDamage(skill_name, requester):
	print("fetching")

@rpc
func ReturnSkillDamage(s_damage, requester):
	print(s_damage)

func CallFetchPlayerStats():
	if not multiplayer.is_server():
		rpc_id(1, "FetchPlayerStats")

@rpc("any_peer")
func FetchPlayerStats():
	print("Fetching")
	
@rpc
func ReturnPlayerStats(stats):
	print("loading player stats")
	update_stats.emit(stats)
