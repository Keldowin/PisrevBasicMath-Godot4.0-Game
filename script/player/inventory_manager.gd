extends Node
# Менеджер инвентаря (взаимодействует с его переменными) используется
# Для смены и использования внутри него предметов

var current_slot = "item2"
var last_slot = "item2"

@onready var hud: GUI = $"../GUI"

func _ready() -> void:
	await hud.ready # Ждём когда тупой интерфейс грузанётся
	
	select_slot("item1")

#Изменение слотов
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("slot_1"): select_slot("item1")
	if Input.is_action_just_pressed("slot_2"): select_slot("item2")
	if Input.is_action_just_pressed("slot_3"): select_slot("item3")

	if Input.is_action_just_pressed("use_item"): use_item()

func select_slot(slot: String) -> void:
	if slot == current_slot:
		if not Pack.is_slot_empty(slot):
			hud.update_item_lable(Pack.return_slot_data(slot, 'name'))

		return
	
	var item_name: String = "Ничего"
	last_slot = current_slot
	
	if not Pack.is_slot_empty(slot):
		item_name = Pack.return_slot_data(slot, 'name')
	
	current_slot = slot
		
	hud.change_slot(current_slot, item_name)

func use_item() -> void: # Использование предмета в слоте
	if Pack.is_slot_empty(current_slot): return

	Pack.use_item(current_slot)
