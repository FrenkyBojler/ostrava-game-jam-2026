class_name Door extends Node3D

@export
var breakable_parent: Node3D

var broken := false

func break_door(direction: Vector3) -> void:
	for item in breakable_parent.get_children():
		var rigidbody = RigidBody3D.new()
		rigidbody.tree_entered.connect(func():
			await get_tree().create_timer(2).timeout
			rigidbody.queue_free()
		)
		item.get_parent().add_child(rigidbody)
		rigidbody.global_position = item.global_position
		item.reparent(rigidbody, true)
		rigidbody.apply_impulse(direction.normalized() * Vector3(randf_range(0, 20), randf_range(0, 20), randf_range(0, 20)))
		randomize()
