extends CharacterBody2D

@onready var animation_tree = get_node("AnimationTree")

var projectile_speed = 600
var life_time = 3
var direction = Vector2(0,0)
var impulse_rotation = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.set('parameters/Fly/blend_position', direction)
	SelfDestruct()


func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _on_IceSpear_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled", true)
	self.hide()

func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name != "Character":
			get_node("CollisionShape2D").set_deferred("disabled", true)
			if collider.is_in_group("Enemies"):
				self.hide()
		
	velocity = direction * projectile_speed
	move_and_slide()
