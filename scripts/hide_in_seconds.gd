class_name HideInSecondsLabel extends Label

func show_and_hide() -> void:
	modulate.a = 1.0
	visible = true
	await get_tree().create_timer(4.0).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 3.0)
	await tween.finished
	visible = false
