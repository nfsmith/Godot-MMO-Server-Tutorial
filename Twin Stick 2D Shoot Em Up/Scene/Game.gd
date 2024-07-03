extends Node2D

var player_spawn = preload("res://Scene/characterTemplate.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Server.verify_success.connect(_OnSuccessfulLogin)
	Server.spawn_player.connect(_SpawnPlayer)
	Server.despawn_player.connect(_DespawnPlayer)

func _OnSuccessfulLogin():
	$GUI.LoginScreen.hide()
	$"Main Scene".show()
	#$"Main Scene".game_started = true

func _SpawnPlayer(player_id, spawn_location):
	if multiplayer.get_unique_id() == player_id:
		pass
	else:
		print("spawning: "+str(player_id))
		var new_player = player_spawn.instantiate()
		new_player.position = spawn_location
		new_player.name = str(player_id)
		get_node("Main Scene/OtherPlayers").add_child(new_player, true)

func _DespawnPlayer(player_id):
	get_node("Main Scene/OtherPlayers/"+str(player_id)).queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
