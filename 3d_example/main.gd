extends Node

onready var spatial = $Spatial
onready var camera = $Spatial/Camera
onready var character = $character
onready var map = $map

func _ready():
	map.generate_map()

func _process(delta):
	character.to = _get_camera_look_position()
	spatial.translation = character.global_transform.origin
	
	var pos_v3 = spatial.global_transform.origin
	var pos_v2 = Vector2(pos_v3.x, pos_v3.z)
	map.update_camera_location(pos_v2)
	
func _get_camera_look_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from :Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir :Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_cast_to :Vector3 = ray_from + ray_dir * 100
	return ray_cast_to * Vector3(1,0,1)
	
func _on_Button_pressed():
	get_tree().change_scene("res://main.tscn")
