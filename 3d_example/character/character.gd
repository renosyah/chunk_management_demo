extends Spatial

export var to :Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = global_transform.origin
	var dir = pos.direction_to(to)
	translation += dir * 5 * delta
	look_at(pos + dir * 10, Vector3.UP)
	

