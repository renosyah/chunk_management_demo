extends Node

onready var noise :OpenSimplexNoise = Global.noise

onready var texture :ImageTexture = ImageTexture.new()
onready var texture_rect = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer/TextureRect

onready var seed_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer/seed_slider
onready var octave_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer2/octave_slider
onready var period_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer3/period_slider
onready var persistence_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer4/persistence_slider
onready var lacunarity_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer5/lacunarity_slider
onready var fallof_start_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer6/fallof_start
onready var fallof_end_slider = $Control/CanvasLayer/Control/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer7/fallof_end

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
	
func _on_fallof_end_drag_ended(value_changed):
	Global.fallof_end = fallof_end_slider.value
	_generate_image()
	
func _on_fallof_start_drag_ended(value_changed):
	Global.fallof_start = fallof_start_slider.value
	_generate_image()
	
func _on_Button_pressed():
	Global.save_noise()
	get_tree().change_scene("res://2d_example/main.tscn")
	
func _on_Button3_pressed():
	Global.save_noise()
	get_tree().change_scene("res://3d_example/main.tscn")
	
func _generate_image():
	var img :Image = Global.generate_image(
		Global.image_size_w, Global.image_size_h,Global.image_scale, Vector2.ZERO
	)
	texture.create_from_image(img)





