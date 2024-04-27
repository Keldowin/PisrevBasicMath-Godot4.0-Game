extends Label

var records_data_local : Dictionary = {
	'game_win_record' : 0, ## Рекорд прохождения игры
}
const file_name : StringName = 'records'

## Проверяем сущ ли файлик с рекородами, если нет то записываем новый
func _ready() -> void:
	hide()
	## Загружаем файлик рекордов
	var records = FileSystem.load_data(file_name)

	if records:
		#Проверка целостности ключей настроек
		records_data_local = records #Загрузка в локальный массив настроек

		if records_data_local['game_win_record'] != 0:
			show()
			text = "Рекорд прохождения "+ humanize_time(records_data_local['game_win_record'])
	else:
		#Создание новых настроек графики исходя из локального словоря настроек
		FileSystem.save_data(file_name, records_data_local)

	Global.records_data = records_data_local

## Перевод из секунд в минуты + секунды 1:00
func humanize_time(seconds: int) -> String:
	var minutes : String = str(int(seconds / 60.0))

	seconds %= 60

	var second = str(seconds)

	if int(second) < 10:
		second = '0' + second

	return minutes + ":" + second
