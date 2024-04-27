class_name GUI extends Control

@onready var slots: Array[Slot] = [
	$Inventory/Bg/HBoxContainer/Slot,
	$Inventory/Bg/HBoxContainer/Slot2,
	$Inventory/Bg/HBoxContainer/Slot3,
]
@onready var item_lable: Label = $Inventory/Item
@onready var inventory_manager: Node = $"../inventory_manager"

@onready var work_done_lable: Label = $Tasks/MarginContainer/Task

@onready var cursor : ColorRect = $Cursor

const white_color: Color = Color("#FFFFFF")
const red_color: Color = Color("#db0206")
const black_color : Color = Color(Color.BLACK)

func _ready() -> void:
	Global.gui = self

	update_work_done_lable(0)

func change_slot(slot: String, item_name: String) -> void:
	var index: int = slot_index(slot)

	slots[index].change_color(red_color) # У активного предмета меняем на красный цвет
	slots[slot_index(inventory_manager.last_slot)].change_color(white_color) # У прошлого предмета меняем на белый цвет

	update_item_lable(item_name)

func update_slot(slot: String, icon: CompressedTexture2D) -> void:
	var index: int = slot_index(slot)

	slots[index].change_item_icon(icon)

func update_item_lable(item_name:String) -> void:
	item_lable.text = item_name

func update_work_done_lable(works: int) -> void:
	work_done_lable.text = "Исправлено работ: "+str(works)+"/5"

func slot_index(slot: String) -> int:
	var index: int = 0

	match slot:
		'item1':
			index = 0
		'item2':
			index = 1
		'item3':
			index = 2

	return index

#Добалвение элементов на интерфейс
func sub(sub_scene : String) -> void:
	var n = load("res://ui/"+sub_scene+".tscn").instantiate() #Загружаем ноду
    
	if n != null: #Если такая существует, то добавляем на сцену
		Global.gui.add_child(n)
	else: 
		push_error("sub ("+sub_scene+") does not exist in path res://ui/")

func can_active(active: bool = false) -> void:
	cursor.color = red_color if active else black_color