extends Spatial

export var offset_position :Vector2

onready var sprite_3d = $Sprite3D

func _ready():
	var tex = ImageTexture.new()
	var image :Image = Global.generate_image(
		Global.image_size_w, Global.image_size_h, Global.image_scale, offset_position
	)
	tex.create_from_image(image, ImageTexture.FLAG_ANISOTROPIC_FILTER)
	sprite_3d.texture = tex
