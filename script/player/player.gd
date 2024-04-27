class_name Player extends Node3D

var cast: Area3D = null

const stamina_value_max: float = 125.0
var stamin_value: float = stamina_value_max
var stamin_regen_value : float = 15.0

@onready var player_controller: CharacterBody3D = %PlayerController
@onready var stamina: ProgressBar = $GUI/StaminBar/MarginContainer/Stamina
@onready var player_detector: RayCast3D = $PlayerController/Head/RayCast3D
@onready var inventory_manager := $inventory_manager
@onready var WalkAudio : AudioStreamPlayer = $WalkSound

@onready var hud: GUI = $GUI

func _ready() -> void:
	Global.game_failed = false

	Global.player = self
	
	player_controller.add_to_group('player')

	player_controller.KEY_BIND_MOUSE_SENS = Global.settings_data['sensetiv']

	stamina.max_value = stamina_value_max

func _process(delta: float) -> void:
	stamin_process(delta)
	intractable_items()
	sound_step()

	if Input.is_action_just_pressed('to_menu'): hud.sub('exit_to_menu')

func stamin_process(delta : float) -> void:
	# Описание работы стамины (На шифт бегать, бегать назад нельзя, стамина тратиться только если игрок ходит)
	if (Input.is_action_pressed('run') and not Input.is_action_pressed(player_controller.KEY_BIND_DOWN)) and is_walking():
		if stamin_value > 0.0:
			stamin_value -= 10 * delta
			
			player_controller.SPEED = 7.0
		else:
			player_controller.SPEED = 4.5
	else:
		player_controller.SPEED = 4.5
		
		if stamin_value < stamina_value_max:
			stamin_value += stamin_regen_value * delta if not is_walking() else 0.0
	
	stamina.value = stamin_value

func sound_step():
	if is_walking() and player_controller.is_on_floor():
		if !WalkAudio.playing:
			WalkAudio.play()
	elif WalkAudio.playing:
		WalkAudio.stop()

func is_walking() -> bool: # Проверяем ходит ли игрок или нет
	return player_controller.velocity.length() > 1.0

func intractable_items() -> void: # Скрипт взаимодействия с предметами
	if player_detector.is_colliding(): # Пересекаеться ли с каким то объектом
		cast = player_detector.get_collider()
		#Проверка соответствиям правилам	
		if cast:
			if not cast.is_in_group('action'):
				cast = null
		else:
			cast = null
	else:
		cast = null
	
	hud.can_active(cast != null)

	#Интерактив с предметами
	if Input.is_action_just_pressed('ui_interact'): action('action')
	if Input.is_action_just_pressed('ui_interact_right'): action('sec_action')
		
func action(metod: String) -> void:
	if cast:
		cast.call(metod)
