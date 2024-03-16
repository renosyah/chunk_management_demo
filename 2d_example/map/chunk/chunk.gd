extends Node2D

export var map_height :float
export var offset :Vector2

var noise :OpenSimplexNoise
var terrain_curve :Curve

onready var label = $texture/Label
onready var texture = $texture

func draw_image(image_size :int):
	var image:Image = Image.new()
	image.create(image_size, image_size, false, Image.FORMAT_RGB8)
	image.lock()
	
	for x in range(image_size):
		for y in range(image_size):
			var pos = Vector2(x, y)
			var value = terrain_curve.interpolate(noise.get_noise_2dv(pos + offset))
			image.set_pixelv(pos, Global.get_pixel_color(value, map_height))
			
	image.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(image, ImageTexture.FLAG_ANISOTROPIC_FILTER)
	texture.texture = tex





