extends Node

var skill_data
var test_data = {
		"Stats": {
			"Strength": 42,
			"Vitality": 68,
			"Dexterity": 37,
			"Intelligence": 24,
			"Wisdom": 17
		}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var skill_data_file = FileAccess.open("res://Data/SkillData - Sheet1.json", FileAccess.READ)
	var json = JSON.new()
	var skill_data_json = json.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = json.data
	
