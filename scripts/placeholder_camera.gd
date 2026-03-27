extends Node3D

const CAMERA_SPEED := 100

func _process(delta: float) -> void:
	rotation_degrees += CAMERA_SPEED * delta * Vector3(0, 1, 0)
