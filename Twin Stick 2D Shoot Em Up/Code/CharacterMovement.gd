extends CharacterBody2D

#const SPEED = 300.0
@export var Bullet: PackedScene
@onready var Camera = get_node("Camera2D")
@onready var animation_tree = $AnimationTree
@onready var animation_mode = animation_tree.get("parameters/playback")
var icespear = preload("res://IceSpear.tscn")
@export var fire_rate = 0.2
var actual_rate = 0.2
var timer = 0

var power = false
var power_timer = 0

@onready var absolute_parent = get_parent()
signal player_died
# controls the player's movement when they die.
var die: bool = false
var max_speed = 300
var speed = 0
var acceleration = 900
var destination = Vector2( )
var movement = Vector2( )
var player_state
var moving = false
var attacking = false

var animation_vector = Vector2( )

func _ready():
	Server.verify_success.connect(_OnLoginSuccess)
	set_physics_process(false)
	# I have no idea why this makes the camera do that thing, but this is cool!
	#Camera.set("position", Vector2(100, 0))



func _input(event):
	if event.is_action_pressed('Click') and not attacking:
		moving = true
		destination = get_global_mouse_position()
	elif event.is_action_pressed('Attack') and not attacking:
		moving = false
		attacking = true
		animation_vector = position.direction_to(get_global_mouse_position())
		animation_tree.set('parameters/Melee/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		Attack()
		

func _OnLoginSuccess():
	set_physics_process(true)
	#Camera.set("position", Vector2(100, 0))
	DefinePlayerState()

func _physics_process(delta):
	MovementLoop(delta)
	DefinePlayerState()

func MovementLoop(delta):
	timer += delta
	if moving == false:
		speed = 0
	else:
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
		velocity = position.direction_to(destination) * speed
		if position.distance_to(destination) > 10:
			move_and_slide()
			animation_vector = velocity.normalized()
			animation_tree.set('parameters/Walk/blend_position', velocity.normalized())
			animation_tree.set('parameters/Idle/blend_position', velocity.normalized())
			animation_mode.travel("Walk")
		else:
			moving = false
			animation_mode.travel("Idle")

#func MovementLoop(delta):
	#timer += delta
	## Power up that you can get :D
	#if power == true:
		#power_timer += delta
		#actual_rate = fire_rate / 2
		#if power_timer >= 10:
			#power = false
	#else:
		#actual_rate = fire_rate
		#power_timer = 0
	#
	## Get the input direction and handle the movement/deceleration.
	#var direction_x = Input.get_axis("Left", "Right")
	#var direction_y = Input.get_axis("Up", "Down")
	#velocity.x = 0
	#velocity.y = 0
	#
	## Stop doing things if you are dead, Respawn on 
	#if die == true:
		#if Input.get_action_raw_strength("Respawn"):
			#Respawn()
		#return
	#
	## if the player isn't dead...
	#if Input.get_action_raw_strength("Shoot") && timer >= actual_rate:
		#
		#var temp = Bullet.instantiate()
		#add_sibling(temp)
		#temp.global_position = get_node("BulletSpawn").get("global_position")
		## this sets the rotation as to where it will fire
		#temp.set("area_direction", (get_global_mouse_position() - self.global_position).normalized())
		## These statements below handle camera shake
		#Camera.set("offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)))
		#timer = 0
	#else:
		#Camera.set("offset", Vector2(0, 0))
	## movement is handled like this
	#if direction_x:
		#velocity.x = direction_x * SPEED
	#if direction_y:
		#velocity.y = direction_y * SPEED
		#
	## look at mouse
	#self.look_at(get_global_mouse_position())
	#move_and_slide()

func DefinePlayerState():
	player_state = {"T": Time.get_ticks_msec(), "P": self.global_position, "A": animation_vector}
	Server.SendPlayerState(player_state)


# all the things that it do when you die.
func Die():
	player_died.emit()
	get_node("Explosive").set_emitting(true)
	get_node("Explosive/Sound").play()
	self.get_node("MeshInstance2D").set("visible", false)
	#Stop Camera and set player to death
	Camera.set("position", Vector2(0, 0))
	die = true
	absolute_parent.game_started = false
	#Wait 1.5 seconds before showing retry screen
	await get_tree().create_timer(1.5).timeout
	#Move Camera to center
	position = Vector2(383,397)
	#Show Retry Background over whole screen
	$"../Retry".show()
	
# Reload Scene
func Respawn():
	$"../Retry".hide()
	absolute_parent.game_started = true
	self.get_node("MeshInstance2D").set("visible", true)
	Camera.set("position", Vector2(100, 0))
	die = false
	#get_parent().reload_current_scene()

func Attack():
	get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
	var icespear_instance = icespear.instantiate()
	var a_rotation = get_angle_to((get_global_mouse_position()))
	var a_position = get_node("TurnAxis").global_position
	var a_direction = animation_vector
	Server.SendAttack(position, animation_vector, a_rotation, a_position, a_direction)
	icespear_instance.direction = a_direction
	icespear_instance.position = a_position
	animation_mode.travel("Melee")
	await get_tree().create_timer(0.2).timeout
	add_sibling(icespear_instance)
	await get_tree().create_timer(0.2).timeout
	attacking = false
