extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.create_default_interface()
var port = 1910
var max_players = 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/x509_Key.key")

# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()

func _process(delta):
	if gateway_api.has_multiplayer_peer():
		gateway_api.poll()

func StartServer():
	
	#network.set_dtls_enabled(true)
	#network.set_dtls_key(key)
	#network.set_dtls_certificate(cert)
	var server_tls_options = TLSOptions.server(key, cert)	
	var error = network.create_server(port, max_players)
	network.host.dtls_server_setup(server_tls_options)
	if error:
		return error
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	print("Gateway Server Started")
	
	multiplayer.peer_connected.connect(_Peer_Connected)
	multiplayer.peer_disconnected.connect(_Peer_Disconnected)

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")

@rpc("any_peer")
func LoginRequest(username, password):
	print("login request received")
	var player_id = multiplayer.get_remote_sender_id()
	Authenticate.AuthPlayer(username, password, player_id)

func ReturnLoginReq(result, player_id, token):
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	print("Disconnecting: "+str(player_id))
	#network.disconnect_peer(player_id)


@rpc("any_peer")
func ReturnLoginRequest(results, token):
	print("returning login request")
