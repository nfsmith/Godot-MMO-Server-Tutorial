extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.verify_success.connect(_OnLoginSuccess)

func _OnLoginSuccess():
	print("Verify Login Success Call")
	$GUI.hide()
	$'DemoScene'.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Stats"):
		$PlayerStats.visible = not $PlayerStats.visible
	if event.is_action_pressed("crouch"):
		Server.CallFetchSkillDamage("Ice Spear", get_instance_id())
