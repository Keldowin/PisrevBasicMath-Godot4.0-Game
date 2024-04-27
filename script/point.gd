@tool
class_name AIPoint extends Node3D

enum {
	NONE,
	Pisarev,
	Gleb,
	Denis,
	Dima
}

var self_position : Vector3 = Vector3.ZERO ## Позиция в мире

## Обозначает для кого будет записываться метка
@export_enum('NONE','Pisarev','Gleb','Denis','Dima') var target_for : int = 0 : 
	set(value):
		target_for = value
		update_lable(target_for)

@onready var debug_lable : Label3D = $debug_lable

func _ready() -> void:
	if Engine.is_editor_hint():
		update_lable(target_for)
		return

	if NONE: 
		push_warning('Deleted no use point '+ str(self)) 
		queue_free()
		return

	hide()

	self_position = global_position ## Позиция в мире
	self_position.y = 1 # Удаляем зависимость от высоты (ставим на уровне игрока)

	global_position = self_position

	## Запись в пулл коордиант в зависимости от выбранной цели

	match target_for:
		Pisarev:
			AIPoints.points['Pisarev'].append(self)
		Gleb:
			AIPoints.points['Gleb'].append(self)
		Denis:
			AIPoints.points['Denis'].append(self)
		Dima:
			AIPoints.points['Dima'].append(self)

func distant_to(target_pos: Vector3) -> float:
	return global_position.distance_squared_to(target_pos)

func update_lable(target: int) -> void:
	if debug_lable == null : return

	var text: String = 'NONE'

	match target:
		Pisarev:
			text = 'Pisarev'
		Gleb:
			text = 'Gleb'
		Denis:
			text = 'Denis'
		Dima:
			text = 'Dima'

	debug_lable.text = text
