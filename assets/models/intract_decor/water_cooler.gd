extends Node3D

@onready var water_sound : AudioStreamPlayer3D = $water_using
@onready var bottle_model : AnimatedSprite3D = $bottle

var water : int = 0
var cooling : bool = false

func _ready() -> void:
	bottle_model.hide()

func pour_water() -> void:
	if not Pack.has_slot_item('bottle_empty') and (water == 0): return
	if cooling: return

	water += 1
	cooling = true
	water_sound.play()

	if water == 1:
		Pack.delete_slot_item()

		bottle_model.show()
		bottle_model.play('empty')
	
	if water >= 3:
		bottle_model.play('full')

	if water >= 4:
		if not Pack.add_item(Pack.build_item_from_id('bottle_water')): return

		bottle_model.hide()


		water = 0

func _on_water_using_finished() -> void:
	cooling = false

