extends Node

onready var noise :OpenSimplexNoise = OpenSimplexNoise.new()
onready var map_land_color :Color = Color(0, 0.282353, 0.039216)
onready var map_sand_color :Color = Color(0.521569, 0.380392, 0)

func _ready():
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

func get_pixel_color(val, map_height :float) -> Color:
	if val > 0.6:
		return lerp_color(Color.saddlebrown,Color.white, val * map_height)
		
	elif val > 0.4:
		return lerp_color(map_land_color, Color.saddlebrown, val * map_height)
		
	elif val > 0:
		return lerp_color(map_sand_color, map_land_color, val * map_height)
		
	elif val > -0.2:
		return map_sand_color
		
	return Color.blue
