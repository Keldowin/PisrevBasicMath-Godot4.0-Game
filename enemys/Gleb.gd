class_name GlebNPC extends NPC

enum {
	Idle, ## Глеб стоит ничего не делает (начало игры)
	Walking, ## Глеб просто ходит по локации
	Hunting, ## Глеб идёт давать пять игроку (ищет его по актуальной инфе о нём) Каждые 15 секунд будет просчёт вероятности этого состояния
	GiveFive
}
var state : int = Idle

@onready var timer : Timer = $timer
@onready var sound : AudioStreamPlayer3D = $sound

const voice : Array[AudioStream] = [
	preload("res://sounds/Gleb/poop1.mp3"),
	preload("res://sounds/Gleb/poop2.mp3"),
	preload("res://sounds/Gleb/hhhhh.mp3"),
	preload("res://sounds/Gleb/dota.mp3")
]

var target : Node3D = null

var giving_five : bool = false

func on_ready() -> void:
	timer.timeout.connect(Callable(_timeout))

	Global.Gleb = self

func on_process(_delta: float) -> void:
	match state:
		Idle:
			can_move = false # Не двигается и вообще ничего не делает
			return
		Hunting: # Стоит ждёт пока пройдёт мимо него игрок
			if target == null: return

			if (global_position.distance_squared_to(target.global_position) < 5) and (not giving_five):
				can_move = false # Не двигается и вообще ничего не делает
				giving_five = true

				give_five()

		Walking: # Ходит бродит
			can_move = true
			if target == null:
				walking()

		GiveFive:
			if not giving_five:
				target = null
				state = Walking
				timer.start()

func _near_enter(_body: Node3D) -> void:
	if state == Idle: return

	var bodies : Array[Node3D] = range_area.get_overlapping_bodies()

	for body_node: Node3D in bodies:
		## Триггер на двери
		if body_node.is_in_group('door'):
			if body_node.get_parent().can_open:
				body_node.get_parent().call_deferred('open',true)
			else:
				state = Walking
				walking()

## Если пришёл в конечную точку то на рандом выбираем чё делать, охотиться или дальше бродить
func _nav_finished() -> void:
	if state == Idle: return
	#print('nav finish')

	## Если не дошли до игрока то идём к ниму ещё разу
	if global_position.distance_squared_to(target.global_position) >= 5 and state == Hunting:
		set_movement_target(target.global_position)
	else:
		walking()
		random_say()

## Каждые 10 секунд Дима чёт говорит
func _timeout() -> void: 
	if state == Idle or state == Hunting: return

	#print('timeout')

	var rand : int = randi_range(0,1)
	if rand:
		hunting()

	random_say()

	_near_enter(null)

## Просто ходим и больше ничего не делаем
func walking() -> void:
	if state == Idle: return

	#print('set walking')

	var new_random_target : AIPoint = get_random_target('Pisarev')
	while(new_random_target == get_random_target('Pisarev')):
		new_random_target = get_random_target('Pisarev')
		print(new_random_target.global_position)

	target = new_random_target
	set_movement_target(target.global_position)

	state = Walking

## Стоим на месте и ждём пока пройдёт игрок
func hunting() -> void:
	if target == null: return
	#print("Gleb hunting")

	target = Global.player.player_controller
	set_movement_target(target.global_position)

	state = Hunting

	timer.stop()

func hunt() -> void:
	timer.start()
	state = Walking

## Заставялет игркоа дать пять иначе не уйдёт
func give_five() -> void:
	if target == null: return
	#print('Дай пять')
	## Показываем сцену с дай пять
	Global.gui.sub('give_five')

	state = GiveFive

func random_say(stream: AudioStream = voice.pick_random()) -> void:
	if sound.playing: return

	sound.stream = stream

	sound.play()
