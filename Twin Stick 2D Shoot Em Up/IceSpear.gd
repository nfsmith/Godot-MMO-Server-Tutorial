extends CharacterBody2D

@onready var animation_tree = get_node("AnimationTree")

var projectile_speed = 600
var life_time = 3
var direction = Vector2(0,0)
var impulse_rotation = Vector2(0,0)
var damage = 10
var original = true

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.set('parameters/Fly/blend_position', direction)
	SelfDestruct()

func SetDamage(s_damage):
	damage = s_damage

func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _on_IceSpear_body_entered(body):
	print("icespear body entered")
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if body.is_in_group("Enemies") and original == true:
		body.OnHit(damage)
	self.hide()

func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name != "Character":
			get_node("CollisionShape2D").set_deferred("disabled", true)
			if collider.is_in_group("Enemies") and original == true:
				collider.OnHit(damage)
				self.hide()
		
	velocity = direction * projectile_speed
	move_and_slide()
