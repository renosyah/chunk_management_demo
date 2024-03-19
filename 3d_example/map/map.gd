extends Node

const chunk_scene = preload("res://3d_example/map/chunk/chunk.tscn")

onready var chunk_management = $chunk_management
export var start_position :Vector2

func generate_map():
	chunk_management.start_position = start_position
	chunk_management.chunk_size = Vector2(Global.image_size_w, Global.image_size_h)
	chunk_management.chunk_margin = Vector2.ZERO
	chunk_management.chunk_scale = chunk_management.ChunkScale.NORMAL
	chunk_management.init_starter_chunk()
	
# update camera current position
# chunk manager will emit signal
# to update your map
func update_camera_location(character_location :Vector2):
	chunk_management.update_camera_location(character_location)
	
# receive signal to update map
# by adding new chunk & removing chunk
func _on_chunk_management_update_map(_chunks_to_remove :Array, _chunks_to_add :Array):
	for i in _chunks_to_remove:
		var data :ChunkManagement.ChunkData = i
		_despawn_chunk(data)
		
	for i in _chunks_to_add:
		var data :ChunkManagement.ChunkData = i
		_spawn_chunk(data)
		
func _spawn_chunk(data :ChunkManagement.ChunkData):
	var offset_position = data.id * Vector2(Global.image_size_w, Global.image_size_h)
	var chunk = chunk_scene.instance()
	chunk.name = data.node_name
	chunk.offset_position = offset_position
	add_child(chunk)
	chunk.translation = Vector3(data.position.x, 0, data.position.y)
	
func _despawn_chunk(data :ChunkManagement.ChunkData):
	var path = NodePath("%s/%s" % [get_path(), data.node_name])
	var chunk = get_node_or_null(path)
	if is_instance_valid(chunk):
		remove_child(chunk)
		chunk.queue_free()
