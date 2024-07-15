extends CharacterBody2D

@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")

var max_speed = 200
var speed = 0
var acceleration = 600
var moving = false
var destination = Vector2()
var attacking = false

func _unhandled_input(event):
	if event.is_action_pressed('Click') and not attacking:
		moving = true
		destination = get_global_mouse_position()
	elif event.is_action_pressed('Attack') and not attacking:
		print("Attack")
		moving = false
		attacking = true
		animation_tree.set('parameters/Melee/blend_position', position.direction_to(get_global_mouse_position()))
		animation_tree.set('parameters/Idle/blend_position', position.direction_to(get_global_mouse_position()))
		Attack()

func _physics_process(delta):
	MovementLoop(delta)
	

func MovementLoop(delta):
	if moving == false:
		speed = 0
	else:
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		velocity = position.direction_to(destination) * speed
		if position.distance_to(destination) > 10:
			animation_tree.set('parameters/Walk/blend_position', velocity.normalized())
			animation_tree.set('parameters/Idle/blend_position', velocity.normalized())
			animation_mode.travel("Walk")
			move_and_slide()
		else:
			moving = false
			animation_mode.travel("Idle")


func Attack():
	animation_mode.travel("Melee")
	await get_tree().create_timer(1.2).timeout
	attacking = false
