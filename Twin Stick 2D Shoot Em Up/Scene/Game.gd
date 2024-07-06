extends Node2D

var player_spawn = preload("res://Scene/characterTemplate.tscn")
var last_world_state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.verify_success.connect(_OnSuccessfulLogin)
	Server.spawn_player.connect(SpawnNewPlayer)
	Server.despawn_player.connect(_DespawnPlayer)
	Server.update_world_state.connect(UpdateWorldState)

func _OnSuccessfulLogin():
	$GUI.LoginScreen.hide()
	$"Main Scene".show()
	#$"Main Scene".game_started = true

func SpawnNewPlayer(player_id, spawn_location):
	if multiplayer.get_unique_id() == player_id:
		pass
	else:
		if not get_node("Main Scene/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instantiate()
			new_player.position = spawn_location
			new_player.name = str(player_id)
			get_node("Main Scene/OtherPlayers").add_child(new_player, true)

func _DespawnPlayer(player_id):
	get_node("Main Scene/OtherPlayers/"+str(player_id)).queue_free()

func UpdateWorldState(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(multiplayer.get_remote_sender_id())
		for player in world_state.keys():
			if get_node("Main Scene/OtherPlayers").has_node(str(player)):
				get_node("Main Scene/OtherPlayers/"+str(player)).MovePlayer(world_state[player]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player, world_state[player]["P"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
