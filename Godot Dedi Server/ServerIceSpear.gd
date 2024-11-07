extends CharacterBody2D


var projectile_speed = 600
var life_time = 3
var direction
var impulse_rotation
var player_id
var damage

func _ready():
	SetDamage()
	SelfDestruct()
	
func SetDamage():
	damage = ServerData.skill_data["Ice Spear"].Damage * (0.1 * get_node("/root/Server/" + str(player_id)).player_stats.Intelligence)

func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()



func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.name != "Character":
			get_node("CollisionShape2D").set_deferred("disabled", true)
			if collider.is_in_group("NPCEnemies"):
				print(collider.get_name())
				var enemy_id = collider.get_name().to_int()
				get_node("/root/Server/Map").NPCHit(enemy_id, damage)
				#collider.OnHit(damage)
			self.hide()
		
	velocity = direction * projectile_speed
	move_and_slide()
