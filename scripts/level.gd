class_name Level extends Node3D

const open_door_prefab = preload("res://prefabs/door_open.tscn")
const close_door_prefab = preload("res://prefabs/door_closed.tscn")

var doors: Array[Node3D] = []

func setup(level_resource: LevelResource, size: int) -> void:
	_place_doors(level_resource, size)

func _place_doors(level_resource: LevelResource, size: int) -> void:
	if level_resource.right_connection == LevelResource.ConnectionState.Open:
		_place_door(3, size, true)
	else:
		_place_door(3, size, false)
	if level_resource.bottom_connection == LevelResource.ConnectionState.Open:
		_place_door(0, size, true)
	else:
		_place_door(0, size, false)

	if level_resource.left_connection == LevelResource.ConnectionState.Open:
		pass
	else:
		_place_door(2, size, false)
		pass
	if level_resource.top_connection == LevelResource.ConnectionState.Open:
		pass
	else:
		_place_door(1, size, false)
		pass
		

func _place_door(door_index: int, size: int, open: bool) -> Node3D:
		var door = open_door_prefab.instantiate() as Door if open else close_door_prefab.instantiate() as Node3D
		add_child(door)
		
		if door_index == 0:
			door.position = Vector3(0, 0, size / 2)
			door.rotate(Vector3.UP, PI)
		if door_index == 1:
			door.position = Vector3(0, 0, -size / 2)
		if door_index == 2:
			door.position = Vector3(-size / 2, 0, 0)
			door.rotate(Vector3.UP, 1.5)
		if door_index == 3:
			door.position = Vector3(size / 2, 0, 0)
			door.rotate(Vector3.UP, -1.5)

		return door


func _on_player_inside_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		print_debug("Player entered")

func _on_player_inside_area_area_exited(area: Area3D) -> void:
	if area.get_parent() is Player:
		print_debug("Player exited")
