extends HBoxContainer

const full_hp := preload("res://prefabs/hp_full.tscn")
const empty_hp := preload("res://prefabs/hp_empty.tscn")

func _ready() -> void:
	GlobalPlayerState.health_changed.connect(_update_hp)
	_update_hp(GlobalPlayerState.current_health, GlobalPlayerState.max_health)

func _update_hp(current: int, max: int) -> void:
	for child in get_children():
		child.queue_free()
	for i in max:
		if i < current:
			var full := full_hp.instantiate() as Control
			add_child(full)
		else:
			var empty := empty_hp.instantiate() as Control
			add_child(empty)
