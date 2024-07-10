extends Node2D

var player_spawn = preload("res://Scene/characterTemplate.tscn")
var enemy_spawn = preload("res://Scene/enemy.tscn")
var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100

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

func SpawnNewEnemy(enemy_id, enemy_dict):
	var new_enemy = enemy_spawn.instantiate()
	new_enemy.position = enemy_dict["EnemyLocation"]
	new_enemy.max_hp = enemy_dict["EnemyMaxHealth"]
	new_enemy.current_hp = enemy_dict["EnemyHealth"]
	new_enemy.type = enemy_dict["EnemyType"]
	new_enemy.state = enemy_dict["EnemyState"]
	new_enemy.name = str(enemy_id)
	get_node("Main Scene/Enemies/").add_child(new_enemy, true)

func _DespawnPlayer(player_id):
	await get_tree().create_timer(0.2).timeout
	get_node("Main Scene/OtherPlayers/"+str(player_id)).queue_free()

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(delta):
	var render_time = Server.client_clock - interpolation_offset
	
	#var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2: # We have a future state
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"])/float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("Main Scene/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					get_node("Main Scene/OtherPlayers/"+str(player)).MovePlayer(new_position)
				else:
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
			for enemy in world_state_buffer[2]["Enemies"].keys():
				if not world_state_buffer[1]["Enemies"].has(enemy):
					continue
				if get_node("Main Scene/Enemies").has_node(str(enemy)):
					var new_position = lerp(world_state_buffer[1]["Enemies"][enemy]["EnemyLocation"], world_state_buffer[2]["Enemies"][enemy]["EnemyLocation"], interpolation_factor)
					get_node("Main Scene/Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("Main Scene/Enemies/" + str(enemy)).Health(world_state_buffer[1]["Enemies"][enemy]["EnemyHealth"])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[2]["Enemies"][enemy])
		elif render_time > world_state_buffer[1].T: # We have no future world_state
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("Main Scene/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("Main Scene/OtherPlayers/" + str(player)).MovePlayer(new_position)
