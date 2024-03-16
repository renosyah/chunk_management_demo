extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var to = get_global_mouse_position()
	var dir = position.direction_to(to)
	position += dir * 200 * delta
	look_at(to)
