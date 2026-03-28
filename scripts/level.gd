class_name Level extends Node3D

const open_door_prefab = preload("res://prefabs/door_open.tscn")
const close_door_prefab = preload("res://prefabs/door_closed.tscn")
const chest_prefab = preload("res://prefabs/chest.tscn")

@onready
var spawn_points: Node3D = %SpawnPoints

var doors: Array[Node3D] = []
var enemies: Array[Node3D] = []
var enemy_scenes: Array[PackedScene] = []
var player: Node3D

var is_player_present := false
var enemies_spawned := false

var used_spawn_points : Array[Vector3] = []

var temp_doors: Array[Node3D] = []

var size: float = -1

var world_pos: Vector2

signal player_entered_level(world_pos: Vector2)

var is_start_level: bool = false

func setup(level_resource: LevelResource, size: int, enemies: Array[PackedScene], player: Node3D, world_pos: Vector2, is_start_level: bool) -> void:
	self.is_start_level = is_start_level
	self.world_pos = world_pos
	self.enemy_scenes = enemies
	self.player = player
	_place_doors(level_resource, size)

func _spawn_enemies() -> void:
	enemies_spawned = true
	
	if spawn_points == null or spawn_points.get_children().is_empty() or is_start_level:
		print_debug("Missing spawn points!")
		return

	var spawn_points_list = spawn_points.get_children()
	for i in randi_range(2, 3):
		var enemy = enemy_scenes.pick_random().instantiate() as Enemy
		
		enemy.enemy_died.connect(func(who: Enemy):
			enemies.remove_at(enemies.find(enemy))
			
			if enemies.is_empty():
				_open_doors()
				_spawn_chest(who.global_position)
		)
		
		var spawn_point = spawn_points_list.pick_random()
		randomize()
		while used_spawn_points.has(spawn_point.global_position):
			spawn_point = spawn_points_list.pick_random()
			randomize()
		used_spawn_points.push_back(spawn_point.global_position)
		
		add_child(enemy)
		enemy.position = Vector3(spawn_point.position.x, 1, spawn_point.position.x)
		enemy.set_movement_target(player)
		enemies.push_back(enemy)
		
func _spawn_chest(position: Vector3) -> void:
	print_debug("TADY")
	var chest = chest_prefab.instantiate() as Chest
	add_child(chest)
	chest.global_position = Vector3(position.x, 1.3, position.z)

func _place_doors(level_resource: LevelResource, size: int) -> void:
	self.size = size
	if level_resource.right_connection == LevelResource.ConnectionState.Open:
		doors.push_back(_place_door(3, size, true))
	else:
		doors.push_back(_place_door(3, size, false))
	if level_resource.bottom_connection == LevelResource.ConnectionState.Open:
		doors.push_back(_place_door(0, size, true))
	else:
		doors.push_back(_place_door(0, size, false))

	if level_resource.left_connection == LevelResource.ConnectionState.Open:
		pass
	else:
		doors.push_back(_place_door(2, size, false))
		pass
	if level_resource.top_connection == LevelResource.ConnectionState.Open:
		pass
	else:
		doors.push_back(_place_door(1, size, false))
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
		
func _prepare_level() -> void:
	if not enemies_spawned and not is_start_level:
		_spawn_enemies() 
		_close_doors()

func _close_doors() -> void:
	for i in 4:
		temp_doors.push_back(_place_door(i, size, false))

func _open_doors() -> void:
	for door in temp_doors:
		door.queue_free()
	temp_doors = []

func _on_player_inside_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		player_entered_level.emit(world_pos)
		is_player_present = true
		_prepare_level()

func _on_player_inside_area_area_exited(area: Area3D) -> void:
	if area.get_parent() is Player:
		is_player_present = false
