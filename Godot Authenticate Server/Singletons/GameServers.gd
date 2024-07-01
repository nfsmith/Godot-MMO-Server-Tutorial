extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.create_default_interface()
var port = 1912
var max_players = 100

var gameserverlist = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gateway_api!= null && gateway_api.has_multiplayer_peer():
		gateway_api.poll()

func StartServer():
	var error = network.create_server(port, max_players)
	if error:
		return error
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	print("GameServerHub started")
	
	network.peer_connected.connect(_Peer_Connected)
	multiplayer.peer_disconnected.connect(_Peer_Disconnected)
	
func _Peer_Connected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Connected")
	"""
	Name is something to add in the loadbalancer tutorial
	"""
	gameserverlist["GameServer1"] = gameserver_id
	print(gameserverlist)
	
func _Peer_Disconnected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Disconnected")
	
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)

@rpc("any_peer")
func ReceiveLoginToken(token):
	pass
