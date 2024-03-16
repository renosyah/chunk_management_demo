extends Node

export var terrain_curve :Curve
onready var noise :OpenSimplexNoise = Global.noise

onready var texture :ImageTexture = ImageTexture.new()
onready var texture_rect = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer/TextureRect

onready var seed_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer/seed_slider
onready var octave_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer2/octave_slider
onready var period_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer3/period_slider
onready var persistence_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer4/persistence_slider
onready var lacunarity_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer5/lacunarity_slider

var map_land_color :Color = Color(0, 0.282353, 0.039216)
var map_sand_color :Color = Color(0.521569, 0.380392, 0)
var image_size :int = 256

func _ready():
	texture_rect.texture = texture
	
	seed_slider.value = noise.seed
	octave_slider.value = noise.octaves
	period_slider.value = noise.period
	persistence_slider.value = noise.persistence
	lacunarity_slider.value = noise.lacunarity
	
	_generate_image()
	
func _on_seed_slider_drag_ended(value_changed):
	noise.seed = seed_slider.value
	_generate_image()

func _on_octave_slider_drag_ended(value_changed):
	noise.octaves = octave_slider.value
	_generate_image()
	
func _on_period_slider_drag_ended(value_changed):
	noise.period = period_slider.value
	_generate_image()
	
func _on_persistence_slider_drag_ended(value_changed):
	noise.persistence = persistence_slider.value
	_generate_image()

func _on_lacunarity_slider_drag_ended(value_changed):
	noise.lacunarity = lacunarity_slider.value
	_generate_image()
	
func _on_Button_pressed():
	var data = {
		"seed" : noise.seed,
		"octaves" : noise.octaves,
		"period" : noise.period,
		"persistence" : noise.persistence,
		"lacunarity" : noise.lacunarity,
	}
	
	var file = File.new()
	file.open("user://map_config.json", File.WRITE)
	file.store_string(JSON.print(data))
	file.close()
	
	var file2 = File.new()
	file2.open("user://map_config.data", File.WRITE)
	file2.store_var(data)
	file2.close()
	
	get_tree().change_scene("res://2d_example/main.tscn")
	
func _generate_image():
	var image:Image = Image.new()
	image.create(image_size, image_size, false, Image.FORMAT_RGB8)
	image.lock()
	
	for x in range(image_size):
		for y in range(image_size):
			var pos = Vector2(x, y)
			var value = terrain_curve.interpolate(noise.get_noise_2dv(pos))
			var value_h = value * 20
			
			if value > 0.6:
				image.set_pixelv(pos, Global.lerp_color(Color.saddlebrown,Color.white , value_h))
				
			elif value > 0.4:
				image.set_pixelv(pos, Global.lerp_color(map_land_color, Color.saddlebrown, value_h))
				
			elif value > 0:
				image.set_pixelv(pos, Global.lerp_color(map_sand_color, map_land_color, value_h))
				
			elif value > -0.2:
				image.set_pixelv(pos, map_sand_color)
				
			else:
				image.set_pixelv(pos, Color.blue)
			
	image.unlock()
	
	texture.create_from_image(image, ImageTexture.FLAG_ANISOTROPIC_FILTER)
	



