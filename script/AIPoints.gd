extends Node
## Скрипт хранящий все координаты точек-ориентиров для ИИ, чтобы они создавали вид передвижения по карте для поиска или просто

var points: Dictionary = {
	'Pisarev': [],
	'Gleb': [],
	'Denis': [],
	'Dima': []
}
## Функция поиска самой возможной ближайшей точкой рядом с целью
func search_closely_point(pointer: String, target: Vector3) -> Array:
	var pointer_distant_to : Array[Array] = []

	for point: AIPoint in points[pointer]:
		## Отсеиваем те что прям оооочень близко 
		if point.distant_to(target) > 50:
			pointer_distant_to.append([point, point.distant_to(target)]) ## AIpoint.tscn / float

	return pointer_distant_to.min()

func clear_points() -> void:
	points = {
	'Pisarev': [],
	'Gleb': [],
	'Denis': [],
	'Dima': []
	}