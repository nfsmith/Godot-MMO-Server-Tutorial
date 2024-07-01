extends Node

var network = ENetMultiplayerPeer.new()
var port = 1911
var max_servers = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()

func StartServer():
	var error = network.create_server(port, max_servers)
	if error:
		return error
	multiplayer.multiplayer_peer = network
	
	network.peer_connected.connect(_Peer_Connected)
	network.peer_disconnected.connect(_Peer_Disconnected)

func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")
	
func _Peer_Disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disonnected")

	
@rpc("any_peer")
func AuthenticatePlayer(username, password, player_id):
	var token
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	if not PlayerData.PlayerIDs.has(username):
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		result = false
	else:
		result = true
		
		randomize()
		#token = str(randi()).sha256_text() + str(Time.get_ticks_msec())
		var random_number = randi()
		print(random_number)
		var hashed = str(random_number).sha256_text()
		print(hashed)
		var timestamp = str(int(Time.get_unix_time_from_system()))
		print(timestamp)
		token = hashed + timestamp
		print(token)
		var gameserver = "GameServer1"
		GameServers.DistributeLoginToken(token, gameserver)
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

@rpc("any_peer")
func AuthenticationResults(result, player_id):
	print("Sending Results")
