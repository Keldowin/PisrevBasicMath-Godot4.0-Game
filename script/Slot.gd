class_name Slot extends Control

@onready var background: ColorRect = $BG
@onready var icon_texture: TextureRect = $ItemIcon

func change_color(color: Color) -> void:
	background.color = color

func change_item_icon(icon: CompressedTexture2D) -> void:
	icon_texture.texture = icon