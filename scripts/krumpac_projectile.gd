extends Projectile

func _physics_process_child(_delta) -> void:
	rotation_degrees += Vector3(0, 0, 1) * 200 * _delta
