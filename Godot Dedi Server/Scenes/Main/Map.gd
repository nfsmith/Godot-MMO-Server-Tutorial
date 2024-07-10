extends Node

var enemy_id_counter = 1
var enemy_maximum = 2
var enemy_types = ["Werebear_Brown"]
var enemy_spawn_points = [Vector2(600, 470), Vector2(300, 600), Vector2(150, 120)]
var open_locations = [0,1,2]
var occupied_locations = {}
var enemy_list = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.timeout.connect(SpawnEnemy)
	self.add_child(timer)

func SpawnEnemy():
	if enemy_list.size() >= enemy_maximum:
		pass
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]
		occupied_locations[enemy_id_counter] =  open_locations[rng_location_index]
		open_locations.remove_at(rng_location_index)
		enemy_list[enemy_id_counter] =  {"EnemyType": type, "EnemyLocation": location, "EnemyHealth": 500, "EnemyMaxHealth": 500, "EnemyState": "Idle", "time_out": 1}
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["EnemyState"] == "Dead":
			if enemy_list[enemy]["time_out"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["time_out"] = enemy_list[enemy]["time_out"] - 1
	#print("spawn enemy called: " + str(enemy_list))

func NPCHit(enemy_id, damage):
	if enemy_list[enemy_id]["EnemyHealth"] <= 0:
		pass
	else:
		print(damage)
		print(enemy_list[enemy_id]["EnemyHealth"])
		enemy_list[enemy_id]["EnemyHealth"] = enemy_list[enemy_id]["EnemyHealth"] - damage
		if enemy_list[enemy_id]["EnemyHealth"] <= 0:
			print(enemy_list)
			print(enemy_id)
			enemy_list[enemy_id]["EnemyState"] = "Dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)
