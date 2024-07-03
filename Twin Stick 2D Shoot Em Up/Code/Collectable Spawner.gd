extends Area2D

@export var Coin: PackedScene
var coinage
@export var PowerUp: PackedScene
@export var power_spawn_rate = 20
var power_timer = 0
# This is found in the debug shape of CollisionShape2D for a representation
@onready var SquareSizeX = get_node("CollisionShape2D").get_shape().get_rect().size.x / 2
@onready var SquareSizeY = get_node("CollisionShape2D").get_shape().get_rect().size.y / 2

func _ready():
	var temp = Coin.instantiate()
	temp.position = self.position + (Vector2(randi_range(-(SquareSizeX), SquareSizeX), randi_range(-(SquareSizeY), SquareSizeY)))
	add_sibling.call_deferred(temp)
	coinage = temp
	
func _process(delta):
	power_timer += delta
	
	if power_timer >= power_spawn_rate:
		power_timer = 0
		var temp = PowerUp.instantiate()
		temp.position = self.position + (Vector2(randi_range(-(SquareSizeX), SquareSizeX), randi_range(-(SquareSizeY), SquareSizeY)))
		add_sibling.call_deferred(temp)
	
	if coinage == null:
		_ready()
