class_name DimaNPC extends NPC

const random_voice : Array[AudioStream] = [
	preload("res://sounds/Dima/boloto.mp3"),
	preload("res://sounds/Dima/chaha.mp3"),
	preload("res://sounds/Dima/skazka.mp3"),
]
const scream_voice : Array[AudioStream] = [
	preload("res://sounds/Dima/banana.mp3"),
	preload("res://sounds/Dima/im.mp3"),
	preload("res://sounds/Dima/peremoga.mp3")
]
const model_states : Array[StringName] = [
	'Idle',
	'Boo',
	'Hoh',
	'Haha'
]

enum {
	Idle, ## Дима стоит ничего не делает (начало игры)
	Walking, ## Дима просто ходит и чёт говорит
	Hunting, ## Дима спрятался и ждёт пока игрок придёт к ниму чтобы напугать
}
var state : int = Idle

@onready var model : AnimatedSprite3D = $Model
@onready var timer : Timer = $timer
@onready var sound : AudioStreamPlayer3D = $sound

var target : Node3D = null

func on_ready() -> void:
	timer.timeout.connect(Callable(_timeout))

	Global.Dima = self

	model.play('Idle')

func on_process(_delta: float) -> void:
	match state:
		Idle:
			can_move = false # Не двигается и вообще ничего не делает
			return
		Hunting: # Стоит ждёт пока пройдёт мимо него игрок
			if target == null: return
			
			can_move = false # Не двигается и вообще ничего не делает
			if global_position.distance_squared_to(target.global_position) < 30:
				boo()

		Walking: # Ходит бродит
			can_move = true
			if target == null:
				walking()

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

		## Триггер видит игрока
		if body_node.is_in_group('player'):
			if state == Hunting:
				boo()
				return
			elif state == Walking:
				random_say()
				return

## Если пришёл в конечную точку то н арандом выбираем чё делать, охотиться или дальше бродить
func _nav_finished() -> void:
	#print('nav finish')
	var rand : int = randi_range(1, 2)

	#print(rand)

	match rand:
		Walking:
			movement_speed = 7.0
			random_say()
			walking()
		Hunting:
			## Если игрок рядом то сначало переходим в walking
			hunting()

## Каждые 10 секунд Дима чёт говорит
func _timeout() -> void: 
	if state == Idle: return

	_near_enter(null)
	random_say()

## Просто ходим и больше ничего не делаем
func walking() -> void:
	if state == Idle: return

	#print('set walking')

	var new_random_target : AIPoint = get_random_target('Dima')
	while(new_random_target == get_random_target('Dima')):
		new_random_target = get_random_target('Dima')
		#print(new_random_target.global_position)

	target = new_random_target
	set_movement_target(target.global_position)

	state = Walking

## Стоим на месте и ждём пока пройдёт игрок
func hunting() -> void:
	#print("Dima hunting")

	target = Global.player.player_controller

	state = Hunting

func hunt() -> void:
	timer.start()
	state = Walking

func random_say(stream: AudioStream = random_voice.pick_random()) -> void:
	if sound.playing: return

	#print('Dima say')

	sound.stream = stream

	model.play(model_states.pick_random())

	sound.play()

## Пугает игрока (тем самым призываем Писарева) а потом дальше ходит 
func boo() -> void:
	#print('boooo')
	
	if Global.Pisarev != null:
		Global.Pisarev.searching_near()

	random_say(scream_voice.pick_random())

	target = null
	state = Walking

	## После того как Дима напугает игрока он ускоряеться пока не дойдёт до слещдующего маршрута
	movement_speed = 13.0
