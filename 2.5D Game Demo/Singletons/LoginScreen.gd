extends Control

#@onready var username_input = get_node("Background/VBoxContainer/UserName")
@onready var username_input = $Background/LoginScreen/Username
#@onready var userpassword_input = get_node("Background/VBoxContainer/Password")
@onready var userpassword_input = $Background/LoginScreen/Password
#@onready var login_button = get_node("Background/VBoxContainer/LoginButton")
@onready var login_button = $Background/LoginScreen/LoginButton
@onready var create_account_button = $Background/LoginScreen/CreateAccountButton
@onready var create_account_confirm_button = $Background/CreateAccount/ConfirmButton
@onready var create_account_back_button = $Background/CreateAccount/BackButton
@onready var create_username_input = $Background/CreateAccount/Emailaddress
@onready var create_password_input = $Background/CreateAccount/Password
@onready var create_confirmpassword_input = $Background/CreateAccount/Confirmpassword



func _ready():
	Gateway.login_fail.connect(_on_login_fail)
	Gateway.login_success.connect(_on_login_success)
	Gateway.create_account_fail.connect(_on_create_account_fail)
	Gateway.create_account_success.connect(_on_create_account_success)
	Server.verify_fail.connect(_on_verify_fail)
	Server.verify_success.connect(_on_verify_success)

func _on_login_button_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide a valid userID and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("attempting to login")
		Gateway.ConnectToServer(username, password, false)

func _on_login_fail():
	print("Login failed...")
	login_button.disabled = false
	create_account_button.disabled = false

func _on_login_success():
	print("Login Success...")
	#get_tree().change_scene_to_file("res://Example World/Objects/World/world.tscn")

func _on_verify_fail():
	login_button.disabled = false

func _on_verify_success():
	print("verify success")

func _on_confirm_button_pressed():
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_password_input.get_text() == "":
		print("Please provide a valid password")
	elif create_confirmpassword_input.get_text() == "":
		print("Please repeat your password")
	elif create_password_input.get_text() != create_confirmpassword_input.get_text():
		print("Passwords don't match")
	elif create_password_input.get_text().length() <= 6:
		print("Password must contain at least 7 characers")
	else:
		create_account_confirm_button.disabled = true
		create_account_back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_password_input.get_text()
		Gateway.ConnectToServer(username, password, true)

func _on_create_account_fail():
	create_account_confirm_button.disabled = false
	create_account_back_button.disabled = false

func _on_create_account_success():
	create_account_back_button.pressed.emit()
