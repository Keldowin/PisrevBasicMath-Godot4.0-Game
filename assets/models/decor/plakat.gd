@tool
extends Sprite3D

@export var image : CompressedTexture2D = null :
	set(value):
		image = value
		change_texture()

func _ready() -> void:
	change_texture()

func change_texture() -> void:
	texture = image