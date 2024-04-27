extends Node
# Класс описывающий работу скриптов использования предметов (Например на ПКМ если взять предмет бумага то её можно порвать)
## Каждая функция должна возвращать true или false

## Съесть шоколад - даёт на 10 секунд ускоренное пополнение стамины и +25 просто стамины
func chocolate() -> bool:
	UISFX.play_path('res://sounds/items/chocolat/eat.mp3')

	Global.player.stamin_value += 25.0

	Global.player.stamin_regen_value = 25.0
	await get_tree().create_timer(10.0).timeout
	Global.player.stamin_regen_value = 15.0

	print("Эффект шоколадки кончился")

	return true

## Вода восстанавливает 50 стамины за раз
func drink() -> bool:
	UISFX.play_path('res://sounds/items/water/drink.mp3')

	Global.player.stamin_value += 50.0

	print("Эффект воды кончился")

	return true

## Блокирует дверь на 15 секунд
func lock_door() -> bool:
	if Global.player.cast == null: return false
	if not Global.player.cast.get_parent() is Door: return false

	UISFX.play_path('res://sounds/items/lock/lock_door.mp3')

	var tmp_door : Door = Global.player.cast.get_parent()

	print(tmp_door.name + " дверь закрыта")

	tmp_door.lock_delay(15.0)

	return true
 
## Звоня по телефону игрок тригеррит главного врага идти там где позвонил игрок (именно там где он стоит) тем самым отвлекая его 
func phone() -> bool:
	if Global.Pisarev == null: return false

	var phone_node := Global.instaniate_node("res://assets/models/COMP/china_audio.tscn", Vector3(Global.player.player_controller.global_position.x, 2.5,Global.player.player_controller.global_position.z))

	Global.Pisarev.kill_phone(phone_node)

	return true

## Используя вд40 можно 3 раза открыть дверь сразу, после чего она исчезнет
var silent_count : int = 3
func silent_open() -> bool:
	## Проверка Ray cast игрока на наличие двери
	if Global.player.cast == null: return false
	if not Global.player.cast.get_parent() is Door: return false

	var tmp_door : Door = Global.player.cast.get_parent()

	## Если нельзя открыть дверь или она уже открыта то не тратим смазку
	if (not tmp_door.can_open) or (tmp_door.door_open): return false

	## Тихо открываем дверь игнорируя рандом открытия
	print(tmp_door.name + " тихо открыта, silent_count: "+ str(silent_count))
	tmp_door.open(true)
	UISFX.play_path('res://sounds/items/wd40/wd40_active.mp3')
	silent_count -= 1

	if silent_count == 0: ## Удаляем предмет, сбрасываем счётчик
		silent_count = 3
		return true

	return false