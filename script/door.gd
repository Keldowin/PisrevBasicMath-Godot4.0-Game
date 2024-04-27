class_name Door extends Node3D

@export_node_path('AnimatedSprite3D') var door_node : NodePath = ''
@onready var door_sprite : AnimatedSprite3D = get_node(door_node)

@export_node_path('CollisionShape3D') var collision_node : NodePath  = ''
@onready var collision: CollisionShape3D = get_node(collision_node)
@onready var static_collision: StaticBody3D = collision.get_parent()

@export_node_path('Timer') var timer_node : NodePath  = ''
@onready var timer: Timer = get_node(timer_node)

@export_node_path('AudioStreamPlayer3D') var open_sound_node : NodePath  = ''
@onready var opensound: AudioStreamPlayer3D = get_node(open_sound_node)

@export_node_path('AudioStreamPlayer3D') var close_sound_node : NodePath  = ''
@onready var closesound: AudioStreamPlayer3D = get_node(close_sound_node)

@export_node_path('Node3D') var door_lock_node : NodePath = ''
@onready var door_lock : Node3D = get_node(door_lock_node)

@export var can_open : bool = true

var door_open : bool = false

var door_clin : bool = false # Если дверь один раз заклинило, то посылать агрессию врагу второй раз не надо там

func _ready() -> void:
	door_lock.hide()

	static_collision.add_to_group('door')

	if not can_open: lock_door()

	door_sprite.play('Close')

func open(ignore_random: bool = false) -> bool:
	if not can_open: 
		return false
		
	if door_open: return false
	
	## Агрегируем врага если дверь открылась не сразу
	## Шанс того что дверь не откроется сначало)
	if randi_range(0, 50) <= 25 and not ignore_random: 
		UISFX.play_path('res://sounds/decor/door/door_brake.mp3')
		
		if not door_clin and Global.Pisarev != null:
			print('door open shooher!!!')
			Global.Pisarev.searching_near()

			door_clin = true

		return false


	timer.start()
	
	open_door()

	return true
	
func _on_timer_timeout() -> void:
	timer.stop()
	
	close_door()

func close_door() -> void:
	door_open = false
	collision.disabled = false
	
	door_sprite.play('Close')
	closesound.play()

func open_door() -> void:
	door_open = true
	collision.disabled = true
	
	door_clin = false

	door_sprite.play('Open')
	opensound.play()

func lock_door() -> void:
	if door_open: close_door()

	door_lock.show()
	can_open = false

func unlock_door() -> void:
	door_lock.hide()
	can_open = true

func lock_delay(sec: float) -> void:
	lock_door()
	await get_tree().create_timer(sec).timeout
	unlock_door()
