extends Node

var world_state


func _physics_process(delta):
	if not get_parent().player_state_collection.is_empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = Time.get_unix_time_from_system()
		get_parent().SendWorldState(world_state)
