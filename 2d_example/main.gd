extends Node

onready var camera_2d = $Camera2D
onready var character = $character
onready var map = $map
onready var player_pos = $Control/CanvasLayer/Control/VBoxContainer/player_pos
onready var current_chunk = $Control/CanvasLayer/Control/VBoxContainer/current_chunk

func _ready():
	character.position = Vector2.ZERO
	
	map.start_position = character.position
	map.generate_map()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var location = character.position
	
	camera_2d.position = location
	map.update_camera_location(location)
	
	player_pos.text = "camera pos : %s" % location
	current_chunk.text =  "current chunk : %s" % map.get_current_chunk_id()

func _on_back_pressed():
	get_tree().change_scene("res://main.tscn")
