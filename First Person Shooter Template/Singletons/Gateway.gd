extends Node

signal login_success
signal login_fail
signal create_account_success
signal create_account_fail

var network = ENetMultiplayerPeer.new()
var gateway_api : MultiplayerAPI
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username
var password
var new_account = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if gateway_api!= null && gateway_api.has_multiplayer_peer():
		gateway_api.poll()

func ConnectToServer(_username, _password, _new_account):
	
	print("connect to server")
	network = ENetMultiplayerPeer.new()
	gateway_api = MultiplayerAPI.create_default_interface()
	#network.set_dtls_enabled(true)
	#network.set_dtls_verify_enabled(false) #set to true when using signed cert
	#network.set_dtls_certificate(cert)
	print(cert)
	var client_tls_options = TLSOptions.client_unsafe(cert)
	username = _username.to_lower()
	password = _password
	new_account = _new_account
	var error = network.create_client(ip, port)
	network.host.dtls_client_setup(ip, client_tls_options) 
	if error:
		print(error)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)

func _OnConnectionFailed():
	print("Failed to connect to login server")
	print("Pop-up server offline or something")
	login_fail.emit()
	create_account_fail.emit()
	
func _OnConnectionSucceeded():
	print("Successfully connected to login server")
	login_success.emit()
	if new_account == true:
		RequestCreateAccount()
	else:
		RequestLogin()

func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""

@rpc("any_peer")
func LoginRequest(username, password):
	print("Requesting Login")

@rpc("any_peer")
func ReturnLoginRequest(results, token):
	print("results received")
	if results == true:
		Server.token = token
		Server.ConnectToServer()
		login_success.emit()
	else:
		print("Please provide correct username and password")
		login_fail.emit()
	multiplayer.connection_failed.disconnect(_OnConnectionFailed)
	multiplayer.connected_to_server.disconnect(_OnConnectionSucceeded)

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

@rpc("any_peer")
func CreateAccountRequest(username, password):
	pass

@rpc("any_peer")
func ReturnCreateAccountRequest(results, message):
	print("results received")
	if results == true:
		print("Account created, please proceed with logging in")
		create_account_success.emit()
	else:
		if message == 1:
			print("Could't create account, please try again")
		elif message == 2:
			print("The username already exists, please use a different one")
		create_account_fail.emit()
	multiplayer.connection_failed.disconnect(_OnConnectionFailed)
	multiplayer.connected_to_server.disconnect(_OnConnectionSucceeded)
