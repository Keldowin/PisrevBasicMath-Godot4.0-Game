extends Node

## Сохранение данных
func save_data(file_name : String,data : Dictionary) -> void:
	var file := FileAccess.open("user://"+file_name, FileAccess.WRITE)
	file.store_var(data)
	print_debug("Saved file with name: "+file_name)

## Загрузка данных
func load_data(file_name : String):
	if FileAccess.file_exists("user://"+file_name):
		var file := FileAccess.open("user://"+file_name, FileAccess.READ)
		var content = file.get_var()
		print_debug("Loaded file with name: "+file_name+" return content")
		return content
	else:
		push_error(file_name + " not loaded")
		return false