extends Area2D

@onready var absolute_parent = get_parent().get_node(".")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		absolute_parent.Coin += 1
		self.queue_free()
