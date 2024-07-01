extends Node

var PlayerIDs

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_data_file = FileAccess.open("res://Data/PlayerData - Sheet1.json", FileAccess.READ)
	var json = JSON.new()
	var player_data_json = json.parse(player_data_file.get_as_text())
	player_data_file.close()
	PlayerIDs = json.data
	
