# Chunk management demo

is a handy module to handle your chunk, if you make open world with procedural terrain this module can help you manage witch chunk need to be remove & added to scene

## How to use

for more detail, tun this project and see map.gd

````

onready var chunk_management = $chunk_management

func generate_map():
	chunk_management.start_position = start_position
	chunk_management.chunk_size = chunk_size
	chunk_management.chunk_margin = 1
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

```

### About GoDot
See [GoDot Game Engine](https://godotengine.org).