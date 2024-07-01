extends Node


# Called when the node enters the scene tree for the first time.
func FetchSkillDamage(skill_name, player_id):
	var damage = ServerData.skill_data[skill_name].Damage * (0.1 * get_node("../"+str(player_id)).player_stats.Intelligence)
	return damage
