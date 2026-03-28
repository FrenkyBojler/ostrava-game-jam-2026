extends Label

func _process(_delta: float) -> void:
	if text.to_int() >= 70:
		label_settings.font_color = Color("67bd31")
	elif text.to_int() >= 40:
		label_settings.font_color = Color("d7bd31")
	else:
		label_settings.font_color = Color("d72131")
