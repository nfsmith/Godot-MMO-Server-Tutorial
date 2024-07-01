extends Control

@onready var strength = get_node("NinePatchRect/VBoxContainer/Strength/StatValue")
@onready var vitality = get_node("NinePatchRect/VBoxContainer/Vitality/StatValue")
@onready var dexterity = get_node("NinePatchRect/VBoxContainer/Dexterity/StatValue")
@onready var intelligence = get_node("NinePatchRect/VBoxContainer/Intelligence/StatValue")
@onready var wisdom = get_node("NinePatchRect/VBoxContainer/Wisdom/StatValue")

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.update_stats.connect(LoadPlayerStats)
	pass


func LoadPlayerStats(stats):
	strength.set_text(str(stats.Strength))
	vitality.set_text(str(stats.Vitality))
	dexterity.set_text(str(stats.Dexterity))
	intelligence.set_text(str(stats.Intelligence))
	wisdom.set_text(str(stats.Wisdom))




	

func _on_visibility_changed():
	Server.CallFetchPlayerStats()
