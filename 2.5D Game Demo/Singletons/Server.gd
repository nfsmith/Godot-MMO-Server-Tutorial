extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909

var token

signal update_stats(stats)
signal verify_success
signal verify_fail
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#ConnectToServer()

func ConnectToServer():
	print("Called ConnectToServer")
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
