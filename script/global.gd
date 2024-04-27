extends Node

var work_done : int = 0

var player : Player = null
var gui : GUI = null

var game_failed: bool = false

var Pisarev : PisarevNPC = null
var Dima : DimaNPC = null
var Denis : DenisNPC = null
var Gleb: GlebNPC = null

var settings_data : Dictionary = {
	'sensetiv' : 0.003
}
var records_data : Dictionary = {
	'game_win_record' : 0
}


@onready var menu_node: PackedScene = preload("res://ui/menu.tscn")
@onready var loading_node: PackedScene = preload("res://ui/loading.tscn")
@onready var death_screen_node : PackedScene = preload("res://ui/death_screen.tscn")
@onready var win_node : PackedScene = preload("res://ui/win.tscn")

#Переключение экрана
func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func pause_game(s:bool=true) -> void: #Установка пазуы на сценах
	get_tree().paused = s
	show_cursor(s)

func show_cursor(s:bool=true) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if !s else Input.MOUSE_MODE_VISIBLE)

#Добалвение объектов на сцену
func instaniate_node(packed_scene, pos = null, parent = null, rot = null) -> Object:
	if packed_scene == null:
		return
		
	var clone
	if typeof(packed_scene) == TYPE_STRING:
		clone = load(packed_scene).instantiate()
	else:
		clone = packed_scene.instantiate()
	
	var root = get_tree().root
	if parent == null:
		parent = root.get_child(root.get_child_count()-1)
	
	parent.add_child(clone)
	
	
	if pos != null:
		clone.global_transform.origin = pos
	if rot != null:
		clone.global_rotation.origin = rot
		
	return clone


func restart_all_variables() -> void:
	Pack.work_done = 0
	Pack.clear()

	game_failed = false

	player = null
	gui = null
	Pisarev = null
	Dima = null
	Global.Denis = null
	Global.Gleb = null

	AIPoints.clear_points()

	ItemFunc.silent_count = 3
