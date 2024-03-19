extends Node
class_name ChunkManagement3D

signal update_map(_chunks_to_remove, _chunks_to_add)

enum ChunkScale { NORMAL, LARGE }

export var start_position :Vector3
export var chunk_size :Vector3 = Vector3(64,64,64)
export(ChunkScale) var chunk_scale = ChunkScale.NORMAL

# id : ChunkData3D
var _chunks :Dictionary = {}

var _current_chunk_id :Vector3
var _last_chunk_id :Vector3

class ChunkData3D:
	var id :Vector3
	var position :Vector3
	var node_name :String
	
func init_starter_chunk():
	var start_id = _position_to_chunk_id(start_position)
	_last_chunk_id = start_id - Vector3.LEFT
	_current_chunk_id = start_id
	
	var dirs :Array = _get_dirs(_get_scale())
	var add :Array = []
	
	for dir in dirs:
		var pos = dir + _current_chunk_id
		var data = create_chunk_data(pos)
		_add_chunk(data)
		add.append(data)
		
	emit_signal("update_map", [], add)
	
func _position_to_chunk_id(pos :Vector3) -> Vector3:
	var chunk_id =  pos / chunk_size
	return Vector3(int(chunk_id.x),int(chunk_id.z), int(chunk_id.y))
	
func create_chunk_data(id :Vector3) -> ChunkData3D:
	var data :ChunkData3D = ChunkData3D.new()
	data.id = id
	data.position = id * chunk_size
	data.node_name = "chunk_%s_%s_%s" % [id.x, id.y, id.z]
	return data
	
func duplicate_chunk_data(data :ChunkData3D) -> ChunkData3D:
	return create_chunk_data(data.id)
	
func get_current_chunk() -> ChunkData3D:
	return _chunks[_current_chunk_id]
	
func first_neighbor_chunks() -> Array:
	var data = []
	var current_chunk = get_current_chunk()
	
	var dirs :Array = _get_dirs(1)
	for dir in dirs:
		var id :Vector3 = dir + current_chunk.id
		if not _chunks.has(id):
			continue
			
		var chunk = _chunks[id]
		if chunk == current_chunk:
			continue
			
		data.append(chunk)
		
	return data
	
func second_neighbor_chunks() -> Array:
	var data = []
	var current_chunk = get_current_chunk()
	var first_neighbor_chunks = first_neighbor_chunks()
	
	var dirs :Array = _get_dirs(2)
	for dir in dirs:
		var id :Vector3 = dir + current_chunk.id
		if not _chunks.has(id):
			continue
			
		var chunk = _chunks[id]
		if chunk == current_chunk:
			continue
			
		if first_neighbor_chunks.has(chunk):
			continue
			
		data.append(chunk)
		
	return data
	
func update_camera_location(to :Vector3):
	if _chunks.empty():
		return
		
	var closest_chunk :ChunkData3D = _get_closest_chunk(to)
	if closest_chunk == null:
		return
		
	if _current_chunk_id == closest_chunk.id:
		return
		
	_last_chunk_id = _current_chunk_id
	_current_chunk_id = closest_chunk.id
	
	_send_update_chunks()
	
func _add_chunk(val :ChunkData3D):
	if _chunks.has(val.id):
		return
		
	_chunks[val.id] = val
	
func _remove_chunk(val :ChunkData3D):
	if not _chunks.has(val.id):
		return
		
	_chunks.erase(val.id)
	
func _get_scale() -> int:
	return 1 if chunk_scale == ChunkScale.NORMAL else 2
	
func _get_dirs(_scale :int) -> Array:
	var dirs :Array = []
	
	for y in range(-_scale, _scale + 1):
		for x in range(-_scale, _scale + 1):
			for z in range(-_scale, _scale + 1):
				dirs.append(Vector3(x, y, z))
			
	return dirs
	
# i know its kinda wacky, but its works!
func _send_update_chunks():
	var remove :Array = []
	var remove_ids :Array = []
	
	if _last_chunk_id != _current_chunk_id:
		remove_ids = _remove_if_exist(
			_get_chunk_ids(_last_chunk_id), 
			_get_chunk_ids(_current_chunk_id)
		)
		remove = _get_chunk_to_remove(remove_ids)
		
	for i in remove:
		_remove_chunk(i)
		
	var add_ids :Array = _remove_if_exist(
		_get_chunk_ids(_current_chunk_id),
		_get_chunk_ids(_last_chunk_id)
	)
	var add :Array = _get_chunk_to_add(add_ids)
	for i in add:
		_add_chunk(i)
	
	emit_signal("update_map", remove, add)
	
func _remove_if_exist(_data :Array, _refrences :Array) -> Array:
	var new_array :Array = []
	for i in _data:
		if not _refrences.has(i):
			new_array.append(i)
			
	return new_array
	
func _get_chunk_ids(from :Vector3) -> Array:
	var datas : Array = []
	var dirs :Array = _get_dirs(_get_scale())
	for dir in dirs:
		var id :Vector3 = dir + from
		datas.append(id)
		
	return datas
	
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
	
func _get_closest_chunk(from :Vector3) -> ChunkData3D:
	if _chunks.empty():
		return null
		
	var list :Array = _chunks.values()
	var val :ChunkData3D = list[0]
	for i in list:
		var data :ChunkData3D = i
		if data == val:
			continue
			
		var a = data.position.distance_squared_to(from)
		var b = val.position.distance_squared_to(from)
		if a < b:
			val = i
			continue
			
	return val
