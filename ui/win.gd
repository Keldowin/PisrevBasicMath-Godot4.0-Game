extends Control

@onready var new_record_label : Label = $new_record

func _ready() -> void:
	## Очищаем все переменные и через 5 сек в меню
	Global.restart_all_variables()

	## Объявление нового рекорда
	new_record_label.hide()
	if Global.records_data['game_win_record'] < FileSystem.load_data('records')['game_win_record']:
		await get_tree().create_timer(4.0).timeout
		UISFX.play_path('res://sounds/music/win.mp3')
		new_record_label.show()

	await get_tree().create_timer(5.0).timeout

	
	get_tree().change_scene_to_packed(Global.menu_node)