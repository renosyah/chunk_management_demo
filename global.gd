extends Node

onready var noise :OpenSimplexNoise = OpenSimplexNoise.new()
onready var map_land_color :Color = Color(0, 0.282353, 0.039216)
onready var map_sand_color :Color = Color(0.521569, 0.380392, 0)
onready var terrain_curve = preload("res://terrain_curve.tres")

const map_height :float = 10.0

var image_size_w :int = 64
var image_size_h :int = 64
var image_scale :float = 1

var fallof_start :float = 0.5
var fallof_end :float = 1.0

func _ready():
	load_noise()
	
func save_noise():
	var data = {
		"seed" : noise.seed,
		"octaves" : noise.octaves,
		"period" : noise.period,
		"persistence" : noise.persistence,
		"lacunarity" : noise.lacunarity,
	}
	
	var file2 = File.new()
	file2.open("user://map_config.data", File.WRITE)
	file2.store_var(data)
	file2.close()
	
func load_noise():
	var file2 = File.new()
	if file2.file_exists("user://map_config.data"):
		file2.open("user://map_config.data", File.READ)
		var data = file2.get_var()
		noise.seed = data["seed"]
		noise.octaves = data["octaves"]
		noise.period = data["period"]
		noise.persistence = data["persistence"]
		noise.lacunarity = data["lacunarity"]
		file2.close()
		
	
func lerp_color(a :Color,b :Color, t :float) -> Color:
	var v = clamp(t / 3.0, 0.0, 1.0)
	
	var rr = a.r + (b.r - a.r) * v
	var gg = a.g + (b.g - a.g) * v
	var bb = a.b + (b.b - a.b) * v
	
	return Color(rr, gg, bb, 1)

func get_noise_value(pos : Vector2) -> float:
	# value range [0, 1], rivers map
	var value = 2 * abs(noise.get_noise_2dv(pos))
	
	# value range [-1,1], islands map
	# var value = noise.get_noise_2dv(pos)
	return terrain_curve.interpolate(value)
	
func generate_heighmap(size_w :int, size_h:int, scale :float, offset :Vector2) -> Dictionary:
	var heigh_map :Dictionary = {}
	for x in range(size_w):
		for y in range(size_h):
			var pos = Vector2(x, y)
			heigh_map[pos] = get_noise_value((pos + offset) * scale)
			
	return heigh_map
	
func generate_image(size_w :int, size_h:int, image_scale :float, offset :Vector2) -> Image:
	var heigh_map :Dictionary = generate_heighmap(
		size_w, size_h, image_scale, offset
	)
	
	var image:Image = Image.new()
	image.create(size_w, size_h, false, Image.FORMAT_RGB8)
	image.lock()
	
	for key in heigh_map.keys():
		var value = heigh_map[key]
		var value_h = value * map_height
		
		if value > 0.2:
			image.set_pixelv(key, Global.lerp_color(map_sand_color, map_land_color, value_h))
			
		elif value > 0 and value < 0.2:
			image.set_pixelv(key, map_sand_color)
			
		else:
			image.set_pixelv(key, Color.blue)
			
	image.unlock()
	return image
	
func _generate_fallof_map(size_w :int, size_h:int) -> Dictionary:
	var fallof_map :Dictionary = {}
	for x in range(size_w):
		for y in range(size_h):
			var key = Vector2(x, y)
			var pos = Vector2(
				float(key.x) / float(size_w) * 2.0 - 1.0,
				float(key.y) / float(size_h) * 2.0 - 1.0
			)
			var t :float = max(abs(pos.x), abs(pos.y))
			
			if t < fallof_start:
				fallof_map[key] = 1.0
				
			elif t > fallof_end:
				fallof_map[key] = 0.0
				
			else:
				fallof_map[key] = smoothstep(1.0, 0.0, inverse_lerp(fallof_start, fallof_end, t))
			
	return fallof_map
