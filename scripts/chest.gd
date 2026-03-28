class_name Chest extends Node3D

func _process(delta: float) -> void:
	rotation_degrees += Vector3.UP * 50 * delta
