extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1911


# Called when the node enters the scene tree for the first time.
func _ready():
	ConnectToServer()

func ConnectToServer():
	var error = network.create_client(ip, port)
	if error:
		return error
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)

func _OnConnectionFailed():
	print("Failed to connect to authentication server")
	
func _OnConnectionSucceeded():
	print("Successfully connected to authentication server")

func AuthPlayer(username, password, player_id):
	print("sending out authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)
	
@rpc("any_peer")
func AuthenticatePlayer(username, password, player_id):
	print("Authenticating Player")
	
@rpc("any_peer")
func AuthenticationResults(result, player_id, token):
	print("results received and replying to player login request")
	Gateway.ReturnLoginReq(result, player_id, token)

@rpc
func CreateAccount(username, password, player_id):
	print("sending out create account request")
	rpc_id(1, "CreateAccount", username, password, player_id)

@rpc("any_peer")
func CreateAccountResults(result, player_id, message):
	print("results received and replying to player create account request")
	Gateway.CallReturnCreateAccountRequest(result, player_id, message)
