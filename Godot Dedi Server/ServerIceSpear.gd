extends CharacterBody2D


var projectile_speed = 600
var life_time = 3
var direction
var impulse_rotation
var player_id

func _ready():
	SelfDestruct()
	
func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()



func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name != "Character":
			get_node("CollisionShape2D").set_deferred("disabled", true)
			#if collider.is_in_group("Enemies") and original == true:
				#collider.OnHit(damage)
			self.hide()
		
	velocity = direction * projectile_speed
	move_and_slide()
