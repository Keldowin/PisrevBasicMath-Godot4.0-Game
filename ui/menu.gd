extends Control

@onready var buttons : Array[Button] = [
	$Buttons/Play,
	$Buttons/Settings,
	$Buttons/Exit
]

@onready var settings_node : Control = $Setting

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pause_game(false)
	Global.show_cursor(true)

	for button in buttons: button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	buttons[0].pressed.connect(Callable(_play))
	buttons[1].pressed.connect(Callable(_settings))
	buttons[2].pressed.connect(Callable(_exit))

func _play() -> void:
	get_tree().change_scene_to_packed(Global.loading_node)

func _settings() -> void:
	settings_node.show()

func _exit() -> void:
	get_tree().quit()