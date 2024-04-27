extends Node

const POOL_SIZE : int = 16

var _index : int = 0
var Volume_static : int = -20

func _ready() -> void:
	for _i:int in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.volume_db = Volume_static
		add_child(player)

func play(path: String) -> void:
	var player := get_child(_index) as AudioStreamPlayer
	player.stream = load("res://sounds/" + path) as AudioStream
	player.play()
	_index = (_index + 1) % POOL_SIZE

func play_path(path, volume : int = Volume_static) -> void:
	var player := get_child(_index) as AudioStreamPlayer
	if typeof(path) == TYPE_STRING: #Есть возможность воспроизвести не загруженный файл и загруженный
		player.stream = load(path) as AudioStream
	else:
		player.stream = path
	player.volume_db = volume
	player.play()
	_index = (_index + 1) % POOL_SIZE

func stop():
	var player := get_child(_index) as AudioStreamPlayer
	player.stop()
	
func is_playing():
	var player := get_child(_index) as AudioStreamPlayer
	return player.playing

