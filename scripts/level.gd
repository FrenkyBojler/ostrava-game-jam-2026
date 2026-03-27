class_name Level extends Node3D

const door_prefab = preload("res://prefabs/door.tscn")

var doors: Array[Node3D] = []

func setup(level_resource: LevelResource, size: int) -> void:
	_place_doors(level_resource, size)

func _place_doors(level_resource: LevelResource, size: int) -> void:
	doors.push_back(_place_door(1, size))
	doors.push_back(_place_door(0, size))
	doors.push_back(_place_door(3, size))
	doors.push_back(_place_door(2, size))
	 
	if level_resource.right_connection:
		doors[2].queue_free()
	if level_resource.bottom_connection:
		doors[1].queue_free()
	if level_resource.left_connection:
		doors[3].queue_free()
	if level_resource.top_connection:
		doors[0].queue_free()

func _place_door(door_index: int, size: int) -> Node3D:
		var door = door_prefab.instantiate() as Door
		add_child(door)
		
		if door_index == 0:
			door.position = Vector3(0, 0, size / 2)
		if door_index == 1:
			door.position = Vector3(0, 0, -size / 2)
		if door_index == 2:
			door.position = Vector3(-size / 2, 0, 0)
			door.rotate(Vector3.UP, 1.5)
		if door_index == 3:
			door.position = Vector3(size / 2, 0, 0)
			door.rotate(Vector3.UP, 1.5)

		return door
