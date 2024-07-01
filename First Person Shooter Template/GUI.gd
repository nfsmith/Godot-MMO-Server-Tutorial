extends Node2D

@onready var PlayerStats = get_node("PlayerStats")
@onready var LoginScreen = $LoginScreen/Background/LoginScreen
@onready var CreateAccount = $LoginScreen/Background/CreateAccount

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Stats"):
		PlayerStats.visible = not PlayerStats.visible
	if event.is_action_pressed("crouch"):
		Server.CallFetchSkillDamage("Ice Spear", get_instance_id())


func _on_create_account_button_pressed():
	LoginScreen.hide()
	CreateAccount.show()


func _on_back_button_pressed():
	CreateAccount.hide()
	LoginScreen.show()
	
