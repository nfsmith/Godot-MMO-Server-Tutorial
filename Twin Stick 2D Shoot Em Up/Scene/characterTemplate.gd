extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var icespear = preload("res://IceSpear.tscn")
var attack_dict = {} # {"Position": position, "AnimationVector": animation_vector}
var state = "Idle"

@onready var animation_tree = $AnimationTree
@onready var animation_mode = animation_tree.get("parameters/playback")

func _physics_process(delta):
	if not attack_dict == {}:
		Attack()


func MovePlayer(new_position, animation_vector):
	if not state == 'Attack':
		animation_tree.set('parameters/Walk/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		if new_position == position:
			animation_mode.travel("Idle")
		else:
			animation_mode.travel("Walk")
			set_position(new_position)

func Attack():
	for attack in attack_dict.keys():
		if attack <= Server.client_clock:
			print(attack_dict[attack]["AnimationVector"])
			state = "Attack"
			animation_tree.set('parameters/Melee/blend_position', attack_dict[attack]["AnimationVector"])
			animation_mode.travel("Melee")
			set_position(attack_dict[attack]["Position"])
			
			
			#get_node("TurnAxis").rotation = get_angle_to(position + attack_dict[attack]["AnimationVector"])
			var icespear_instance = icespear.instantiate()
			#icespear_instance.impulse_rotation = get_node("TurnAxis").rotation
			icespear_instance.position = get_node("TurnAxis").global_position
			icespear_instance.direction = attack_dict[attack]["AnimationVector"]
			attack_dict.erase(attack)
			await get_tree().create_timer(0.2).timeout
			add_sibling(icespear_instance)
			await get_tree().create_timer(0.2).timeout
			
			state = "Idle"
