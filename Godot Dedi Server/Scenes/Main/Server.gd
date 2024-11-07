extends Node

var network = ENetMultiplayerPeer.new()
var port = 1909
var max_players = 100

var expected_tokens = []
var player_state_collection = {}

@onready var player_verification_process = get_node("PlayerVerification")

# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()

func StartServer():
	var error = network.create_server(port, max_players)
	if error:
		return error
	multiplayer.multiplayer_peer = network
	
	multiplayer.peer_connected.connect(_Peer_Connected)
	multiplayer.peer_disconnected.connect(_Peer_Disconnected)

func _Peer_Connected(player_id):
	#start(player_id)
	print("User " + str(player_id) + " Connected")
	player_verification_process.Start(player_id)
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	if(has_node(str(player_id))):
		print(player_state_collection)
		player_state_collection.erase(player_id)
		print(player_state_collection)
		get_node(str(player_id)).queue_free()
		rpc_id(0, "DespawnPlayer", player_id)


@rpc("any_peer")
func DespawnPlayer(player_id):
	pass

func _on_TokenExpiration_timeout():
	var current_time = Time.get_ticks_msec()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >=30:
				expected_tokens.remove(i)
	print("Expected Tokens:")
	print(expected_tokens)

@rpc("any_peer")
func FetchServerTime(client_time):
	var player_id = multiplayer.get_remote_sender_id()
	ReturnServerTime.rpc_id(player_id, Time.get_ticks_msec(), client_time)
	
@rpc
func ReturnServerTime(server_time, client_time):
	pass

@rpc("any_peer")
func DetermineLatency(client_time):
	var player_id = multiplayer.get_remote_sender_id()
	ReturnLatency.rpc_id(player_id, client_time)

@rpc
func ReturnLatency(client_time):
	pass

@rpc("any_peer")
func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")

@rpc("any_peer")
func ReturnToken(token):
	var player_id = multiplayer.get_remote_sender_id()
	player_verification_process.Verify(player_id, token)

@rpc("any_peer")
func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	if result == true:
		rpc_id(0, "SpawnNewPlayer", player_id, Vector2(50,50))
	
@rpc
func SpawnNewPlayer(player_id, location):
	pass

@rpc("any_peer", "unreliable")
func ReceivePlayerState(player_state):
	var player_id = multiplayer.get_remote_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state

func SendWorldState(world_state):
	ReceiveWorldState.rpc_id(0, world_state)

@rpc("unreliable")
func ReceiveWorldState(world_state):
	pass

@rpc("any_peer")
func Attack(position, animation_vector, spawn_time, a_rotation, a_position, a_direction):
	var player_id = multiplayer.get_remote_sender_id()
	get_node("WorldMap").SpawnAttack(spawn_time, a_rotation, a_position, a_direction, player_id)
	ReceiveAttack.rpc_id(0, position, animation_vector, spawn_time, player_id)

@rpc
func ReceiveAttack(position, animation_vector, spawn_time, player_id):
	pass




@rpc("any_peer")
func FetchPlayerStats():
	var player_id = multiplayer.get_remote_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id,"ReturnPlayerStats", player_stats)

@rpc
func ReturnPlayerStats(stats):
	print("Returning")
