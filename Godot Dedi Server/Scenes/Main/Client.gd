extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Calling server")
	ConnectToServer()

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
	print("Successfully connected")

func CallFetchSkillDamage(skill_name, requester):
	rpc_id(1, "FetchSkillDamage", skill_name, requester)
	

@rpc("any_peer")
func FetchSkillDamage(skill_name, requester):
	print("fetching")

@rpc
func ReturnSkillDamage(s_damage, requester):
	print(s_damage)
