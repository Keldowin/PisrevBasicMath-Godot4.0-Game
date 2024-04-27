extends Control

@onready var words : Label = $word

const death_words : Array[String] = [
	"Молчите.",
	"2, отчислен",
	"Я вас завалю",
	"Мне стыдно за вас",
	"Делайте что хотите, но не мешайте проводить пару",
	"Я всё слышу",
	"Свободен гомик",
	"Шоколад спасает от грабителя",
	"Дай пять!",
	"Осторожно открывай двери",
	"Чя чя)",
	"Может скрываться в кабинете и орать",
	"Пошли воды нальём",
	"о как",
	"о так"
]

func _ready() -> void:
	words.text = death_words.pick_random()

	await get_tree().create_timer(5.0).timeout

	get_tree().change_scene_to_packed(Global.menu_node)