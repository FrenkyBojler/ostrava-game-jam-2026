class_name Level extends Node3D

const door_prefab = preload("res://prefabs/door.tscn")

var door_north: Door
var door_south: Door
var door_west: Door
var door_east: Door

@onready
var doors: Array[Door] = [door_north, door_south, door_east, door_west]
var door_placeholders: Array[Node]

func _ready() -> void:
	for child in get_children():
		if child.name == "Doors":
			door_placeholders = child.get_children()
			break
	assert(not door_placeholders.is_empty(), "There is no Doors object in the level: " + name)

func setup(level_resource: LevelResource) -> void:
	_place_doors(level_resource)

func _place_doors(level_resource: LevelResource) -> void:
	_place_door(3, level_resource.right_connection)
	_place_door(1, level_resource.bottom_connection)
	
	if level_resource.left_connection:
		_remove_door(2)
	else:
		_place_door(2, false)
	if level_resource.top_connection:
		_remove_door(0)
	else:
		_place_door(0, false)

func _place_door(door_index: int, is_opened: bool) -> void:
		doors[door_index] = door_prefab.instantiate() as Door
		add_child(doors[door_index])
		doors[door_index].global_position = door_placeholders[door_index].global_position
		doors[door_index].global_rotation = door_placeholders[door_index].global_rotation
		door_placeholders[door_index].queue_free()
		
		if is_opened:
			doors[door_index].opened()
		else:
			doors[door_index].closed()

func _remove_door(door_index: int) -> void:
	door_placeholders[door_index].queue_free()
