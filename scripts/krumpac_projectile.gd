extends Projectile

func _physics_process_child(_delta) -> void:
	rotation_degrees += Vector3.FORWARD * 10 * _delta
