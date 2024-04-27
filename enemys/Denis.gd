class_name DenisNPC extends NPC

const voices : Array[AudioStream] = [
	preload("res://sounds/Denis/robber.mp3"),
	preload("res://sounds/Denis/chlel.mp3")
]
enum {
	Idle, ## Денис стоит ничего не делает (начало игры)
	Walking, ## Денис идёт на новую точку чтобы там начать ждать игрока
	GrabWait, ## Денис ждёт чтобы украсть что-то у игрока
}
var state : int = Idle

@onready var sound : AudioStreamPlayer3D = $sound

@onready var grab_area : Area3D = $grab_area

var target : Node3D = null

func on_ready() -> void:
	grab_area.body_entered.connect(Callable(_grab_area_entered))

	Global.Denis = self

func on_process(_delta: float) -> void:
	match state:
		Idle:
			can_move = false # Не двигается и вообще ничего не делает
			return
		GrabWait: # Стоит ждёт пока пройдёт мимо него игрок
			can_move = false # Не двигается и вообще ничего не делает

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

func _grab_area_entered(_body: Node3D) -> void:
	if state == Idle or state != GrabWait: return

	var bodies : Array[Node3D] = grab_area.get_overlapping_bodies()

	for body_node: Node3D in bodies:
		## Триггер на двери
		if body_node.is_in_group('player'):
			grab_item()

## Как только Денис пришёл на точку ожидания то переходим в режим грабления
func _nav_finished() -> void:
	#print('nav finish')
	
	if state == Walking:
		state = GrabWait

## Просто ходим и больше ничего не делаем
func walking() -> void:
	if state == Idle: return

	#print('set walking')

	var new_random_target : AIPoint = get_random_target('Denis')
	while(new_random_target == get_random_target('Denis')):
		new_random_target = get_random_target('Denis')
		print(new_random_target.global_position)

	target = new_random_target
	set_movement_target(target.global_position)

	state = Walking

## Крадём у игрока рандомный предмет кричим и уходим в другое место
## Если у игрока есть шоколадка то крадём только её
func grab_item() -> void:
	## Если у игрока ничего нет то лол уходим
	if Pack.is_slot_empty('item1') and Pack.is_slot_empty('item2') and Pack.is_slot_empty('item3'): 
		#print("Нет предметов у игрока вообще")

		sound.stream = voices[1]
		sound.play()

		walking()
		state = Walking
		return

	## Если есть шоколад то крадём его
	var chocolate_slot : String = Pack.find_item_slot('chocolate')
	if chocolate_slot != '':
		Pack.delete_slot_item(chocolate_slot)
		print("Украл шоколад")

		sound.stream = voices[0]
		sound.play()

		walking()
		state = Walking
		return

	## Иначе крадём рандомный предмет с шансом 50/50
	var rand : int = randi_range(0,1)
	if rand:
		Pack.delete_slot_item(Pack.get_random_slot())

		sound.stream = voices[0]
		sound.play()
	else:
		sound.stream = voices[1]
		sound.play()

	walking()
	state = Walking

func hunt() -> void:
	state = Walking
