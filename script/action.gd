class_name Action extends Area3D

@export_category("ItemData")
@export var item_id: StringName = "item"
@export var is_item: bool = false

@export_category("Actions")
@export var on_parent: String = ''
@export var on_right_parent: String = ''

@export var on_remove: bool = false
@export var on_remove_parent: bool = false

func _ready() -> void:
	hide()

func action() -> void:
	if is_item:
		if not Pack.items_data.has(item_id): return

		var item_data: Dictionary = Pack.items_data[item_id]

		if not Pack.add_item(item_data): # Если оказалось что мест в инвентаре нет, то выходим из функции
			return

	active_callable(on_parent)
	delete_action()

func sec_action() -> void:
	active_callable(on_right_parent)

func delete_action() -> void:
	if on_remove_parent:
		get_parent().queue_free()
	else:
		if on_remove:
			queue_free()

func active_callable(callable: String) -> void:
	if callable:
		get_parent().call(callable)
