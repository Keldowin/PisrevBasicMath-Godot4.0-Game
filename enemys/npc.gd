class_name NPC extends CharacterBody3D

##INFO: Инициализируем нужные нам переменные

static var debug_mode : bool = false

@export_node_path('NavigationAgent3D') var nav_agent_node : NodePath = ''
## Переменная объекта NavAgent3D
@onready var nav_agent : NavigationAgent3D = get_node(nav_agent_node)

@export_node_path('Area3D') var range_node : NodePath = ''
@onready var range_area : Area3D = get_node(range_node)

## Скорость нпс
@export var movement_speed: float = 4.0

var can_move : bool = true

func _ready() -> void:
	add_to_group('enemy')
	on_ready()

	nav_agent.debug_enabled = debug_mode

	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	nav_agent.navigation_finished.connect(Callable(_nav_finished))

	range_area.body_entered.connect(Callable(_near_enter))

	nav_agent.avoidance_enabled = false
	nav_agent.use_3d_avoidance = false
	nav_agent.max_speed = movement_speed

func set_movement_target(movement_target: Vector3) -> void:
	await get_tree().physics_frame

	nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	on_process(delta)

	moving()

func moving() -> void:
	if not can_move: return

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if not can_move: return

	velocity = safe_velocity
	move_and_slide()

## Свойство открывания дверей для всех НПС
func _near_enter(_body: Node3D) -> void:
	pass

func _nav_finished() -> void:
	pass

func on_process(_delta: float) -> void:
	pass

func on_ready() -> void:
	pass

func get_random_target(pointer: String) -> AIPoint:
	var point : AIPoint = AIPoints.points[pointer].pick_random()

	return point
