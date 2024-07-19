extends Node2D

var icespear = preload("res://ServerIceSpear.tscn")
var enemy_spawn = preload("res://Serverenemy.tscn")

func SpawnAttack(spawn_time, a_rotation, a_position, a_direction, player_id):
	var icespear_instance = icespear.instantiate()
	icespear_instance.player_id = player_id
	icespear_instance.position = a_position
	icespear_instance.direction = a_direction
	add_child(icespear_instance)

func SpawnEnemy(enemy_id, location):
	var new_enemy = enemy_spawn.instantiate()
	new_enemy.position = location
	new_enemy.name = str(enemy_id)
	get_node("Main Scene/Enemies").add_child(new_enemy, true)
