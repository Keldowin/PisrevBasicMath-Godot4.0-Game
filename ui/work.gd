extends Control

@onready var task_title : Label = $copybook/Task/task_lable
@onready var task : Label = $copybook/Task/task_text
@onready var enter: LineEdit = $copybook/Task/LineEdit
@onready var enter_button : Button = $copybook/enter

@onready var mark: Label = $copybook/mark

@onready var sound : AudioStreamPlayer = $Sound


var tasks : int = 0
var answer : int = 0

var work_fail : bool = false

const crucked_words : Array[String] = [
	'В̶̼͍͈̫͕̈́̿͡Ӹ̶͚͓́̂ ̷̳͎͈̋̅͛̄ͅВ̶̠̭̺̔͌̿͜С̷̧̱̟̘̈̂̑͝Е̴͕̺̃͋͌̚ ̷̩̣̿͝У̷̙̭́̉͊͗̕М̴̼͉̦̈̔͆Р̴̣͌͒̓Ё̷̠̘̂̐̂̇̅Т̴͇̬͓̳̾͑͝Ё̴̢̢͟',
	'6̸̢̝́̋6̴̙̹̺̮͍̐͊̌̚͡6̷̯̝̔̇̕͝ ̷͙̙̙̜͋͐̑͝-̶̧̪̆ ̵̛̛͔͉͍̠̔6̷̧̧͕̿̀̉̚͜ͅ6̷̨̢̢͕͕̊͐̆͝6̶̧͖͈̾͑̑͑',
	'ЗА ВОДКУ ХОТЬ ВЕСЬ КОЛЛЕДЖ',
	'БЕГИ БЕГИ',
	')))',
	'ОТЧИСЛЕН',
	'Н̷͕̂̓Е̶̼̖̦̼̥͂̔͝ ̴̰͎̟͆̈̀̽͝З̶̰̌В̶͕̓̌̀̾О̶͖͉̬̀̌̾͝Н̵̼̞͔̈́̿И̷̰̳̹̰͑͌͂̈́̕ ̸̰͔̑́̄͟Б̶͓͇̥̗͙̀̓Л̴̢̰͙͟͡͝Я̷̢̜͍̦̆̐̔͜Т̸͍͛Ь̵̲̮̋ͅ',
	'Я ВСЁ СЛЫШУ',
	'100 ГРАММ И ТЫ БАМ БАМ',
	'УМЕРЕТЬ',
	'Б̶͈̑͝Е̴̙̠̞̑̈́͛̈Г̴̧̨̟̮͋̍͐И̸͚̼͊ ̷̤̯̍С̸͚̘̹͕̈́̿͐̚ͅУ̸̺͉̔̆̓̓ͅК̸̺͓̯̾͟А̶̧̼͡͠͝)̷͍̋',
	'СМАКАЙ МАИ ЯЙЦА',
	'О КАК)',
	'О ТАК)',
	'ZV',
	'ТИШЕ БЛЯТЬ',
	'ПУГАЛО ЁБАННОЕ)',
	'ЗАЧЁТ 2)',
	'С̸̫̣̖́͋̈́͑П̴̡̜̬͉̀̅̕А̴̭͖͙̂͡С̵̺̹̲̇̽̊̽И̷̠̇͋́͘ ̶̡̦̺͊̊̏С̶̘̖̮̦̟̈́͗П̵͇͔̜͍͊̅͐̃А̷̗̦̞̻̫̋͛С̸̧̖̤̻̋̒͌И̸͕̰̭̓̓̎͘ ̴̟̦̌͗͗̂̚͜С̴͓̫͎͌͘͠͡П̶̺̭̖͝А̶̡̯̩͎͒ͅС̵̳̮̠͖̅̄̾͘И̸̡̪̓',
	'Я̷̮̕ ̶̨̨͖̱̫̀̏͒̑̓С̵̨̮̹͈̳͐̋̔̉͠З̸̛̟̿̍̈́Д̷̫̬̹͘А̵̬̱͚͛̈́͘͠ͅИ̶̹͔̬̔͛͟͟͡)̷͈͈̂̍̑̍'
]

func _ready():
	Global.pause_game()
	mark.hide()

	if Pack.work_done == 0:
		UISFX.play_path('res://sounds/pisarev/math_intro.mp3', 0)
		sound.play()

	gen_task()
	
func gen_task() -> void:
	tasks += 1

	if tasks == 4:
		exit()
		
		return

	# Генерируем сложное 3 задание
	if tasks == 3 and Pack.work_done == 0:
		task_title.text = "Задание "+crucked_words.pick_random()
		answer = 66666
		task.text = "Решите: "+crucked_words.pick_random()

		return

	var random_nums : Array[int] = [randi_range(-10, 10), randi_range(0, 10)]
	var random_operand : int = randi_range(0, 1)

	var string_operand : String = ' + ' if random_operand == 1 else ' - '

	answer = random_nums[0] + random_nums[1] if random_operand == 1 else random_nums[0] - random_nums[1]

	var string_question : String = str(random_nums[0]) + string_operand + str(random_nums[1])

	task_title.text = "Задание "+str(tasks)
	task.text = "Решите: "+string_question

func _on_line_edit_text_submitted(new_text:String):
	if not enter.editable: return
	if new_text == '': return

	mark.show()

	if (int(new_text)) == answer:
		mark.text = '5'
		enter.text = ''

		gen_task()
	else:
		mark.text = '2'
		enter.text = ''
		
		work_fail = true

		sound.stop()

		gen_task()

func exit() -> void:
	if work_fail:
		if Global.Pisarev.state != 0:
			## Провалил работу, а главый враг не знает? Щас узнает
			Global.Pisarev.agrssiv_detect() 

		## В начале игры заводим главого врага чтобы он на нас охотился
		elif Pack.work_done == 0:
			## Агрессируем всех врагов
			##
			##
			## Агрессируем всех врагов
			Global.Pisarev.hunt()
			Global.Pisarev.agrssiv_detect()

			Global.Dima.hunt()
			Global.Denis.hunt()
			Global.Gleb.hunt()

	Pack.add_work_done()

	task_title.text = "Задание "+crucked_words.pick_random()
	task.text = "Решите: "+crucked_words.pick_random()

	enter.editable = false
	enter_button.disabled = true

	await get_tree().create_timer(3.5).timeout

	Global.pause_game(false)
	queue_free()


func _on_enter_pressed() -> void:
	_on_line_edit_text_submitted(enter.text)
