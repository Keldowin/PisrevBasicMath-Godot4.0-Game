extends Node
# Система инвентаря

## Зарезервированные предметы
## У предмета всегда должны быть заполнены все ключи!!!! 
const items_data: Dictionary = {
	'chocolate': {
		'name': 'Шоколад',
		'icon': preload("res://assets/items_view/chocolat/texture.png"),
		'func': 'chocolate',
		'id': 'chocolate',
	},
	'bottle_empty': {
		'name': 'Пустая бутылка',
		'icon': preload("res://assets/items_view/bottle/bottle_empty.png"),
		'func': null,
		'id': 'bottle_empty',
	},
	'bottle_water': {
		'name': 'Бутылка с водой',
		'icon': preload("res://assets/items_view/bottle/bottle_with_water.png"),
		'func': 'drink',
		'id': 'bottle_water',
	},
	'credit_card': {
		'name': 'Кредитка',
		'icon': preload("res://assets/items_view/credit_card/credit_card.png"),
		'func': null,
		'id':'credit_card'
	},
	'lock': {
		'name': 'Замок',
		'icon': preload("res://assets/lock/texture.png"),
		'func': 'lock_door',
		'id': 'lock'
	},
	'phone': {
		'name': 'Звонилка',
		'icon': preload("res://assets/items_view/phone/texture.png"),
		'func': 'phone',
		'id': 'phone',
	},
	'wd40': {
		'name': 'Смазка',
		'icon' : preload("res://assets/items_view/wd40/texture.png"),
		'func' : 'silent_open',
		'id': 'wd40'
	}
}

## Инвентарь игрока на 3 слота, структура предмета описана в `items_data`
var inventory: Dictionary = {
	'item1': null,
	'item2': null,
	'item3': null,
}

## Исправлено работ
var work_done : int = 0

# Добавление предмета в инвентарь, если он добавился то вернёт true
func add_item(item_data: Dictionary) -> bool:
	if item_data == {}: return false

	for item in inventory:
		if is_slot_empty(item):
			inventory[item] = item_data

			# Обновление hud
			Global.gui.update_slot(item, item_data['icon'])
			Global.player.inventory_manager.select_slot(item)

			return true

	return false

## Удаление предмета (например при применении)
func delete_slot_item(slot: String = Global.player.inventory_manager.current_slot) -> void:
	if not inventory.has(slot):
		push_error(slot+' does not exist in inventory')
		return

	inventory[slot] = null

	# Обновление hud
	Global.gui.update_slot(slot, null)

	if slot == Global.player.inventory_manager.current_slot:
		Global.gui.update_item_lable('Ничего')

## Проверка существует ли данный предмет у игрока в одном из слоте (Проверяет по id предмета!!!)
## Возвращает true если нашёл первый предмет в слоте уд. условию
func has_item(item_id: StringName) -> bool:
	for item in inventory:
		if inventory[item] == null:
			continue

		if inventory[item]['id'] == item_id:
			return true

	return false

## Проверка существует ли данный предмет у игрока в ОПРЕДЕЛЁННОМ слоте (Проверяет по id предмета!!!)
## Возвращает true если нашёл предмет в указанном слоте (по умолчанию ищет в текущем слоте)
func has_slot_item(item_id: StringName, slot:String = Global.player.inventory_manager.current_slot) -> bool:
	return (inventory[slot] != null) and (inventory[slot]['id'] == item_id)

## Проверяет не пустой ли слот (Возвращает true если слот пустой)
func is_slot_empty(slot: String) -> bool:
	return inventory[slot] == null

## Использование предмета
## Удаляет его после использования
func use_item(slot: String) -> void:
	if not inventory.has(slot): return
	if inventory[slot]['func'] == null: return

	if ItemFunc.call(inventory[slot]['func']): delete_slot_item(slot)

## Добавление выполненной работы
func add_work_done() -> void:
	work_done += 1

	Global.gui.update_work_done_lable(work_done)

## Из уникального id предмета соберёт его словарь данных
func build_item_from_id(item_id: StringName) -> Dictionary:
	if not items_data.has(item_id): return {}

	return items_data[item_id]

## Меняет один объект на другой в слоте
func change_slot_item(slot_from: String, slot_to: String) -> void:
	if not inventory.has(slot_from) or not inventory.has(slot_to): return

	inventory[slot_to] = inventory[slot_from]
	inventory[slot_to] = null

## Найдёт в каком слоте предмет
func find_item_slot(item_id: StringName) -> String:
	for slot in inventory:
		if is_slot_empty(slot):
			continue

		if inventory[slot]['id'] == item_id:
			return slot

	return ''

## Вернёт данные о слоте
func return_slot_data(slot: String, data: StringName):
	if not inventory.has(slot): return
	if not inventory[slot].has(data): return
	
	return inventory[slot][data]

func clear() -> void:
	inventory = {
		'item1' : null,
		'item2' : null,
		'item3' : null
	}

func get_random_slot(not_null: bool = true) -> String:
	if not not_null: return inventory.keys().pick_random()

	var random_slot : String = inventory.keys().pick_random()
	while(is_slot_empty(random_slot)):
		random_slot = inventory.keys().pick_random()

	return random_slot