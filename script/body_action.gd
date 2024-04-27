extends Area3D

@export var on_player : String = ''
@export var on_remove : bool = false

func _ready():
	hide()

func _on_body_entered(body:Node3D) -> void:
	if body.is_in_group('player'):
		if on_player and get_parent().has_method(on_player):
			get_parent().call_deferred(on_player)

		if on_remove:
			queue_free()