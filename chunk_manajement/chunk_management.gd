extends Node
class_name ChunkManagement

signal update_map(_chunks_to_remove, _chunks_to_add)

export var start_position :Vector2
export var chunk_size :Vector2 = Vector2(64,64)
export var chunk_margin :Vector2 = Vector2.ONE
export var chunk_range :int = 1

# id : ChunkData
var _chunks :Dictionary = {}

# smaller 1 range for calculation purposes
var _chunks_temp :Dictionary = {} 

var _current_chunk_id :Vector2
var _last_chunk_id :Vector2

class ChunkData:
	var id :Vector2
	var position :Vector2
	var node_name :String
	
func init_starter_chunk():
	var start_id = _position_to_chunk_id(start_position)
	_last_chunk_id = start_id - Vector2.LEFT
	_current_chunk_id = start_id
	
	_chunks.clear()
	_chunks_temp.clear()
	
	var positions :Array = _get_adjacent_chunks(_current_chunk_id, chunk_range)
	var add :Array = []
	for pos in positions:
		var data = create_chunk_data(pos)
		_add_chunk(data)
		add.append(data)
		
	# temp
	positions = _get_adjacent_chunks(_current_chunk_id, 1)
	for id in positions:
		_chunks_temp[id] = create_chunk_data(id)
		
	emit_signal("update_map", [], add)
	
func _position_to_chunk_id(pos :Vector2) -> Vector2:
	var chunk_id =  pos / chunk_size
	return Vector2(int(chunk_id.x),int(chunk_id.y))
	
func create_chunk_data(id :Vector2) -> ChunkData:
	var data :ChunkData = ChunkData.new()
	data.id = id
	data.position = id * (chunk_size + chunk_margin)
	data.node_name = "chunk_%s_%s" % [id.x, id.y]
	return data
	
func duplicate_chunk_data(data :ChunkData) -> ChunkData:
	return create_chunk_data(data.id)
	
func get_current_chunk() -> ChunkData:
	return _chunks[_current_chunk_id]
	
func update_camera_location(to :Vector2):
	if _chunks.empty():
		return
		
	var closest_chunk :ChunkData = _get_closest_chunk(to)
	if closest_chunk == null:
		return
		
	if _current_chunk_id == closest_chunk.id:
		return
		
	_last_chunk_id = _current_chunk_id
	_current_chunk_id = closest_chunk.id
	
	_send_update_chunks()
	
func _add_chunk(val :ChunkData):
	if _chunks.has(val.id):
		return
		
	_chunks[val.id] = val
	
func _remove_chunk(val :ChunkData):
	if not _chunks.has(val.id):
		return
		
	_chunks.erase(val.id)
	
# so this function basicaly compare
# both old array of chunk & new array of chunks
# and decide to check what to keep, what to add, and to delete
func _send_update_chunks():
	var data :Dictionary = _compare_adjacent_tiles(
		_chunks.keys(),
		_get_adjacent_chunks(_current_chunk_id, chunk_range)
	)
	
	 # update global chunks
	var removed :Array = _get_chunk_to_remove(data["removed"])
	for i in removed:
		_remove_chunk(i)
	
	var added :Array = _get_chunk_to_add(data["added"])
	for i in added:
		_add_chunk(i)
		
	_chunks_temp.clear()
	
	# update temp
	var positions = _get_adjacent_chunks(_current_chunk_id, 1)
	for id in positions:
		_chunks_temp[id] = create_chunk_data(id)
		
	emit_signal("update_map", removed, added)
	
func _compare_adjacent_tiles(old_tiles: Array, new_tiles: Array) -> Dictionary:
	var old_dict :Dictionary = {}
	var new_dict :Dictionary = {}
	
	for tile in old_tiles:
		old_dict[tile] = true
	
	for tile in new_tiles:
		new_dict[tile] = true
	
	var added :Array = []
	var removed :Array = []
	var duplicate :Array = []
	
	for tile in new_tiles:
		if old_dict.has(tile):
			duplicate.append(tile)
		else:
			added.append(tile)
			
	for tile in old_tiles:
		if not new_dict.has(tile):
			removed.append(tile)
			
	return { "added": added, "removed": removed, "duplicate": duplicate }
	
func _get_chunk_to_remove(chunk_ids :Array) -> Array:
	var datas : Array = []
	for id in chunk_ids:
		if _chunks.has(id):
			datas.append(duplicate_chunk_data(_chunks[id]))
			
	return datas
	
func _get_chunk_to_add(chunk_ids :Array) -> Array:
	var datas : Array = []
	for id in chunk_ids:
		if _chunks.has(id):
			continue
			
		datas.append(create_chunk_data(id))
		
	return datas
	
func _get_closest_chunk(cam_location :Vector2) -> ChunkData:
	if _chunks_temp.empty():
		return null
		
	var list :Array = _chunks_temp.values()
	var val :ChunkData = list[0]
	var val_range :float = val.position.distance_squared_to(cam_location)
	
	for i in list:
		var data :ChunkData = i
		if data == val:
			continue
			
		var a = data.position.distance_squared_to(cam_location)
		if a < val_range:
			val = i
			val_range = a
			continue
			
	return val
	
const _ARROW_DIRECTIONS = [
	Vector2.UP, Vector2.DOWN, 
	Vector2.LEFT, Vector2.RIGHT,
]

const _DIAGONAL_DIRECTIONS = [
	Vector2.UP + Vector2.LEFT,
	Vector2.UP + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.DOWN + Vector2.RIGHT,
]

# get_snap_direction and get_chunks_in_cone
# its a custom open function to display chunk with POV
func get_snap_direction(facing_direction :Vector2) -> Vector2:
	if facing_direction == Vector2.ZERO:
		return Vector2.ZERO
		
	var directions :Array = _ARROW_DIRECTIONS + _DIAGONAL_DIRECTIONS
	facing_direction = facing_direction.normalized()
	
	var best_dir = directions[0]
	var best_dot = -999999.0
	
	for d in directions:
		var dot = facing_direction.dot(d.normalized())
		
		if dot > best_dot:
			best_dot = dot
			best_dir = d
	
	return best_dir

func get_chunks_in_cone(center: Vector2, forward_dir: Vector2, reverse:bool = false) -> Array:
	var result = []
	var tiles: Array = _get_adjacent_chunks(center, chunk_range)
	tiles.erase(center)
	
	var half_angle = deg2rad(90.0) # 90° cone total
	for tile in tiles:
		if tile == center:
			continue
			
		var angle = forward_dir.angle_to(center.direction_to(tile))
		if abs(angle) > half_angle:
			if reverse:
				result.append(create_chunk_data(tile))
				
			continue
			
		if not reverse:
			result.append(create_chunk_data(tile))
	
	return result
	
func _get_adjacent_chunks(from: Vector2, radius: int) -> Array:
	var directions :Array = _ARROW_DIRECTIONS + _DIAGONAL_DIRECTIONS
	var visited := {}
	var frontier := [from]
	visited[from] = true
	
	for _step in range(radius):
		var next_frontier := []
		for current in frontier:
			for dir in directions:
				var neighbor = current + dir
				if not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	var tiles :Array = visited.keys().duplicate()
	visited.clear()
	
	return tiles # [Vector2]
