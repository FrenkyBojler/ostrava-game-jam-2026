extends HBoxContainer

const full_hp := preload("res://prefabs/hp_full.tscn")
const empty_hp := preload("res://prefabs/hp_empty.tscn")

func _ready() -> void:
	GlobalGameState.player_health_changed.connect(func(current: int, max: int):
		for child in get_children():
			child.queue_free()
		for i in max:
			if i < current:
				var full := full_hp.instantiate() as Control
				add_child(full)
			else:
				var empty := empty_hp.instantiate() as Control
				add_child(empty)
	)
