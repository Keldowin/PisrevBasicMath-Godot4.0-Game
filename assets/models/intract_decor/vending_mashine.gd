extends Node3D

@onready var sigls : Array[MeshInstance3D] = [
	$Buyer/buy,
	$Buyer/defolt,
	$Buyer/nobuy,
]

var work : bool = false

func _ready() -> void:
	show_signals(1)

func buy_snak() -> void:
	if work: return
	if not Pack.has_slot_item('credit_card'): return

	work = true

	var random := randi_range(0, 1)

	## Не прокнуло
	if random == 0:
		show_signals(2)
		UISFX.play_path('res://sounds/decor/vending_machine/error.mp3')

		await get_tree().create_timer(5.0).timeout

		work = false
		show_signals(1)

		return

	show_signals(0)
	UISFX.play_path('res://sounds/decor/vending_machine/sucess.mp3')
	await get_tree().create_timer(2.0).timeout
	UISFX.play_path('res://sounds/decor/vending_machine/snak_drop.mp3')

	work = false
	show_signals(1)

	Pack.delete_slot_item() ## Удалит взятый в руку предмет
	Pack.add_item(Pack.build_item_from_id('chocolate'))

func show_signals(signal_index: int) -> void:
	for sigl in sigls: sigl.hide()

	sigls[signal_index].show()
