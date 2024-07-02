extends Node2D


@onready var LoginScreen = $LoginScreen/Background/LoginScreen
@onready var CreateAccount = $LoginScreen/Background/CreateAccount




func _on_create_account_button_pressed():
	LoginScreen.hide()
	CreateAccount.show()


func _on_back_button_pressed():
	CreateAccount.hide()
	LoginScreen.show()
	
