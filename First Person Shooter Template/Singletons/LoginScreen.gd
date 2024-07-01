extends Control

#@onready var username_input = get_node("Background/VBoxContainer/UserName")
@onready var username_input = $Background/LoginScreen/Username
#@onready var userpassword_input = get_node("Background/VBoxContainer/Password")
@onready var userpassword_input = $Background/LoginScreen/Password
#@onready var login_button = get_node("Background/VBoxContainer/LoginButton")
@onready var login_button = $Background/LoginScreen/LoginButton
@onready var create_account_button = $Background/LoginScreen/CreateAccountButton


func _ready():

	Gateway.login_fail.connect(_on_login_fail)
	Gateway.login_success.connect(_on_login_success)
	Server.verify_fail.connect(_on_verify_fail)
	Server.verify_success.connect(_on_verify_success)

func _on_login_button_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide a valid userID and password")
	else:
		login_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("attempting to login")
		Gateway.ConnectToServer(username, password)

func _on_login_fail():
	print("Login failed...")
	login_button.disabled = false

func _on_login_success():
	print("Login Success...")
	#get_tree().change_scene_to_file("res://Example World/Objects/World/world.tscn")

func _on_verify_fail():
	login_button.disabled = false
	

func _on_verify_success():
	print("verify success")

