extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.create_default_interface()
var ip = "127.0.0.1"
var port = 1912

@onready var gameserver = get_node("/root/Server")

# Called when the node enters the scene tree for the first time.
func _ready():
	ConnectToServer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ConnectToServer():
	var error = network.create_client(ip, port)
	if error:
		return error
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)

func _OnConnectionFailed():
	print("Failed to connect to Game Server Hub")

func _OnConnectionSucceeded():
	print("Successfully connected to Game Server Hub")

@rpc("any_peer")
func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
