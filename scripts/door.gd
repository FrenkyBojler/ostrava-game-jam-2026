class_name Door extends Node3D

@export
var breakable_parent: Node3D

var broken := false

@onready
var door_open_mesh := %door_open as Node3D
@onready
var door_clopse_mesh := %door_closed as Node3D

func _ready() -> void:
	show_open()

func break_door(direction: Vector3) -> void:
	broken = true
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

func show_open() -> void:
	toggle_colliders(door_clopse_mesh, true)
	door_clopse_mesh.visible = false
	door_open_mesh.visible = true

func show_close() -> void:
	toggle_colliders(door_clopse_mesh, false)
	door_clopse_mesh.visible = true
	door_open_mesh.visible = false

func toggle_colliders(node: Node3D, toggle: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", toggle)
		toggle_colliders(child, toggle)
