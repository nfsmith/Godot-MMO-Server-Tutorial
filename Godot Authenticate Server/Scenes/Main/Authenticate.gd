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
	var gateway_id = multiplayer.get_remote_sender_id()
	var hashed_password
	var token
	var result
	if not PlayerData.PlayerIDs.has(username):
		result = false
	else:
		var retrieved_salt = PlayerData.PlayerIDs[username].Salt
		hashed_password = GenerateHashedPassword(password, retrieved_salt)
		if not PlayerData.PlayerIDs[username].Password == hashed_password:
			result = false
		else:
			result = true
			
			randomize()
			token = str(randi()).sha256_text() + str(int(Time.get_ticks_msec()))
			var gameserver = "GameServer1"
			GameServers.DistributeLoginToken(token, gameserver)
	
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

@rpc("any_peer")
func AuthenticationResults(result, player_id):
	print("Sending Results")

@rpc("any_peer")
func CreateAccount(username, password, player_id):
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt}
		PlayerData.SavePlayerIDs()

	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)


func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt

func GenerateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2, 18) #8 pow(2, 18) 262144
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		#print("password @ round: " + str(rounds) + " is: " + hashed_password)
		rounds -= 1
	return hashed_password


@rpc
func CreateAccountResults(result, player_id, message):
	pass
