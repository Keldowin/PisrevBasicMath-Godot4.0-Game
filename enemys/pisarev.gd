class_name PisarevNPC extends NPC

@onready var timer_to_move : Timer = $Timer
@onready var slap : AudioStreamPlayer3D = $slap

@onready var vision : Area3D = $Vision

@onready var kill_cam : Camera3D = $Screamer/Camera3D
@onready var kill_sound : AudioStreamPlayer = $Screamer/Scim

@onready var model : AnimatedSprite3D = $Model

enum {
	Idle, ## Враг стоит (в начале игре например и ничего не делает)
	Attack, ## Враг видит игрока и идёт к нему ищя самый лучший маршрут
	Searching ## Враг потерял игрока и теперь ищет его

}
var state : int = Idle

var target : Node3D = null

var move: bool = true

var kill_phone_active : bool = false ## Пока телефон не сдохнет то идём к ниму любой ценой (если конечно не увидим игрока)

## Кол попыток через которых враг установит новый путь
var search_iterations : int = 0
var search_iterations_max : int = 10

func on_ready() -> void:
	timer_to_move.timeout.connect(Callable(_timeout))
	kill_sound.finished.connect(Callable(_return_to_menu))

	Global.Pisarev = self

	model.play('Idle')

func on_process(_delta: float) -> void:
	match state:
		Idle:
			can_move = false # Не двигается и вообще ничего не делает
			return
		Searching: # Ищет игрока (основывает своё движение на точках-ориентирах на карте)
			if target == null:
				searching() if randi_range(0, 1) == 1 else searching_near() ## Враг рандомно будет искать игрока, но он может и пойти проверять рядом с точкой маршрута
				#print('Начинаем искать игрока')

			if search_iterations >= search_iterations_max:
				if kill_phone_active: kill_phone_active = false

				#print('Не смог наверно пройти, ищём что-то новое')

				searching_near() ## Если так и не смогли найти ничего, то сужаем круг обзора

		Attack: # Враг атакует игрока и знает где он находиться пока он не дальше чем
			## Потеря игрока
			if global_position.distance_squared_to(Global.player.player_controller.global_position) > 600:
				## Если потерял игрока, то пытаемся найти ближяйшую с ним точку и пойти туда
				#print('Потерял игрока')

				state = Searching
				target = null

				return
			
			target = Global.player.player_controller

## Если пришёл в конечную точку
func _nav_finished() -> void:
	## Если состояние Searching и дистанция до игрока больше 250, то ищём дальше
	print('nav finish')
	print(global_position.distance_squared_to(Global.player.player_controller.global_position))
	if state == Searching:
		if kill_phone_active:
			#print("Телефон уничтожен")
			kill_phone_active = false

		searching()

		#print('Ищём игрока ещё раз')

func _timeout() -> void:
	#print('timeout / state: '+ str(state), ' search_int: '+ str(search_iterations))
	search_iterations += 1

	movement_speed = 6.0 + float(Pack.work_done)
	timer_to_move.wait_time = 3.0 - float(Pack.work_done / 3.0) if (1.5 - float(Pack.work_done / 3.0)) > 0 else 0.5

	_near_enter(null)

	if move:

		move = false
		can_move = true

		slap.play()

		if target != null:
			set_movement_target(target.global_position)

	else:
		move = true
		can_move = false


func hunt() -> void:
	timer_to_move.start()
	state = Searching

func _near_enter(_body: Node3D) -> void:
	if state == Idle: return

	var bodies : Array[Node3D] = range_area.get_overlapping_bodies()

	for body_node: Node3D in bodies:
		## Триггер на двери
		if body_node.is_in_group('door'):
			if body_node.get_parent().can_open:
				body_node.get_parent().call_deferred('open',true)
			else:
				state = Searching

				print('Дверь закрыта, ищем что-то другое')
		
				searching()
		
		## Триггер поймал игрока
		if body_node.is_in_group('player'):
			kill_player()

## Если враг увидел игрока то он начинает его атаковать
func _on_vision_body_entered(_body: Node3D) -> void:
	if state == Idle or state == Attack: return
	
	var bodies : Array[Node3D] = vision.get_overlapping_bodies()

	for body_node: Node3D in bodies:
		if body_node.is_in_group('player'):
			_timeout()
			state = Attack

func searching() -> void:
	if state == Idle or state == Attack or kill_phone_active: return

	var new_random_target : AIPoint = get_random_target('Pisarev')
	while(new_random_target == get_random_target('Pisarev')):
		new_random_target = get_random_target('Pisarev')
		#print(new_random_target.global_position)

	target = new_random_target
	set_movement_target(target.global_position)

	#print('Установлен новый рандомный путь')

	search_iterations_max = 5 ## Устанавилваем максимальное количество шагов для достижения маршрута

	search_iterations = 0

	state = Searching

## Функция ищет игрока по ближайшей к ниму точке
func searching_near() -> void:
	if state == Idle or state == Attack or kill_phone_active: return

	#print("searching_near active")

	target = AIPoints.search_closely_point('Pisarev', Global.player.player_controller.global_position)[0]
	
	#print("Search point is: "+ target.name)

	set_movement_target(target.global_position)
	search_iterations_max = 10

	search_iterations = 0

	state = Searching

## Функция детекта агресии, вызывается если открыть дверь либо неправильно решить задание, устанавлиает прямой путь к игрока
## И даёт 20 search_iterations_max (шагов для совершения операции)
func agrssiv_detect() -> void:
	#print("agrssiv_detect")

	target = Global.player.player_controller
	set_movement_target(target.global_position)

	search_iterations_max = 10

	search_iterations = 0

	state = Searching

## Триггер на телефон
func kill_phone(phone: Node3D) -> void:
	#print("kill_phone")

	kill_phone_active = true

	target = phone
	set_movement_target(target.global_position)

	search_iterations_max = 8

	search_iterations = 0

	state = Searching

func kill_player() -> void:
	if Global.Gleb.give_five:
		Global.Gleb.hide()

	target = null
	timer_to_move.stop()
	state = Idle

	model.play('Scream')

	Global.player.queue_free()
	Global.game_failed = true

	kill_cam.current = true

	## Эффект затемнения камеры
	var tween: Tween  = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(kill_cam, 'far', 0.01, 2.0)

	kill_sound.play()

## Возвращает игрока после смерти обратно в меню (когда закончиться звук скримера)
func _return_to_menu() -> void:
	Global.restart_all_variables()
	
	if randi_range(0, 100) <= 10:
		Global.gui.sub('blue_screen')
	else:
		get_tree().change_scene_to_packed(Global.death_screen_node)
