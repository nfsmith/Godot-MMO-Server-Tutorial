extends CharacterBody2D

@export_group("Stats")
@export var speed = 100.0
@export var health: int = 1
# assigned on ready, this stops a flood of errors.
@export_group("Player Things")
@export var player_name = "Character"
var player
# In the main scene, this goes to the very very top node! one node down, there should
# be the character and the spawners
@onready var absolute_parent = get_parent()
# Used to increase the score (Spawners should be the child of a "scene" node)
@export var score_value = 1
@onready var health_bar = $HealthBar
var max_hp = 100
var current_hp = 100
var state
var type

func _ready():
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	if not health_bar == null:
		health_bar.value = percentage_hp
	#if state == "Idle":
		#get_node("AnimationPlayer").play("Idle_SW")
	if state == "Dead":
		#get_node("AnimationPlayer").stop()
		#get_node("Sprite").set_frame(219)
		get_node("CollisionShape2D").set_deferred("disabled", true)
		#get_node("HitBox").set_deferred("disabled", true)
		health_bar.hide()
	if absolute_parent.get_node_or_null(player_name) != null:
		player = absolute_parent.get_node(player_name)
		player.player_died.connect(_OnPlayerDied)
		

func _OnPlayerDied():
	self.queue_free()


func _process(delta):
	# These 3 little lines of code handle movement! Don't ask me why velocity has to be set this way.
	#if player != null:
		#self.look_at(player.get("position"))
		#self.velocity = Vector2(0, 0)
		#self.position.x = move_toward(self.position.x, player.get("position").x, speed * delta)
		#self.position.y = move_toward(self.position.y, player.get("position").y, speed * delta)
	#
	#move_and_slide()
	pass

# Destroy the player
func _on_area_detector_body_entered(body):
	if body.name == player_name && body.get("die") != true:
		body.Die()

# Get hit, or die.
func hit():
	var damage = 100
	OnHit(damage)
		


func MoveEnemy(new_position):
	set_position(new_position)

func Health(health):
	if health != current_hp:
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0:
			OnDeath()

func HealthBarUpdate():
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	health_bar.value = percentage_hp
	if percentage_hp >= 60:
		health_bar.set_modulate("14e114")
	elif percentage_hp <= 60 and percentage_hp > 25:
		health_bar.set_modulate("e1be32")
	else:
		health_bar.set_modulate("e11e1e")

func OnHit(damage):
	Server.NPCHit(get_name().to_int(), damage)
	#current_hp -= damage
	#if current_hp <= 0:
		#OnDeath()

func OnDeath():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("AreaDetector").set_deferred("disabled", true)
	#get_node("AnimationPlayer").play("Death_SW")
	health_bar.hide()
	z_index = -1
