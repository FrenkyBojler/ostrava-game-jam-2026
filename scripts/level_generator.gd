extends Node3D

@export
var player_scene: PackedScene
@export
var enemy_scenes: Array[PackedScene]

@export
var start_level_scene: PackedScene
@export
var levels_scenes: Array[PackedScene]
@export
var level_size : float

const NUMBER_OF_ROOMS := 10

var levels: Array[LevelResource]
var levels_placed: Array[Vector2]

func _ready() -> void:
	assert(start_level_scene != null, "Missing start level scene!")
	assert(levels_scenes.size() != 0, "Missing levels scenes!")
	assert(level_size != null, "Missing level size!")

	_generate_level()

func _generate_level() -> void:
	var rows = _get_number_of_rows()
	levels_placed.push_back(Vector2((rows - 1) / 2, (rows - 1) / 2))
	
	var player = player_scene.instantiate() as Node3D
	
	while(levels_placed.size() != NUMBER_OF_ROOMS):
		_place_random_room(rows)
	_instantiate_levels(rows, player)
	
	add_child(player)
	player.global_position = Vector3(((rows - 1) / 2) * level_size, 5, ((rows - 1) / 2) * level_size)
	
func _instantiate_levels(rows: int, player: Node3D) -> void:
	levels_placed.sort_custom(func(a: Vector2, b: Vector2):
		return a.length() <= b.length()
	)
	
	for level in levels_placed:
		
		_instantiate_level(level, rows, player)

func _instantiate_level(pos: Vector2, rows: int, player: Node3D) -> void:
	var is_start_level := pos == Vector2((rows - 1) / 2, (rows - 1) / 2)
	
	var level_resource = LevelResource.new()
	var level_prefab = levels_scenes.pick_random() if not is_start_level else start_level_scene
	randomize()
	var level_instance = level_prefab.instantiate() as Level
	
	level_resource.right_connection = LevelResource.ConnectionState.EdgeOfMap if not (pos.x + 1 < rows) else LevelResource.ConnectionState.Open if _has_right_neighbour(pos) else LevelResource.ConnectionState.Closed
	level_resource.bottom_connection = LevelResource.ConnectionState.EdgeOfMap if not (pos.y + 1 < rows) else LevelResource.ConnectionState.Open if _has_bottom_neighbour(pos) else LevelResource.ConnectionState.Closed
	level_resource.top_connection = LevelResource.ConnectionState.EdgeOfMap if not (pos.y - 1 >= 0) else LevelResource.ConnectionState.Open if _has_top_neighbour(pos) else LevelResource.ConnectionState.Closed
	level_resource.left_connection = LevelResource.ConnectionState.EdgeOfMap if not (pos.x - 1 >= 0) else LevelResource.ConnectionState.Open if _has_left_neighbour(pos) else LevelResource.ConnectionState.Closed
	
	add_child(level_instance)
	
	level_instance.global_position = Vector3(pos.x * level_size, 0, pos.y * level_size)
	level_instance.setup(level_resource, level_size)
	
	if not is_start_level:
		_spawn_enemies(pos, player)

func _spawn_enemies(pos: Vector2, player: Node3D) -> void:
	var enemy = enemy_scenes.pick_random().instantiate() as Enemy
	add_child(enemy)
	enemy.global_position = Vector3(pos.x * level_size, 1, pos.y * level_size)
	enemy.set_movement_target(player)

func _place_random_room(rows: int) -> void:
	var random_level := levels_placed.pick_random() as Vector2
	var empty_neighbours = _get_empty_neighbours(random_level, rows)
	
	while(levels_placed.size() != NUMBER_OF_ROOMS and empty_neighbours.is_empty()):
		random_level = levels_placed.pick_random() as Vector2
		empty_neighbours = _get_empty_neighbours(random_level, rows)

	var neighbour = empty_neighbours.pick_random() as Vector2
	levels_placed.push_back(neighbour)
	
func _has_right_neighbour(pos: Vector2) -> bool:
	return levels_placed.find_custom(func(item: Vector2):
		return item == Vector2(pos.x + 1, pos.y)
	) != -1
	
func _has_left_neighbour(pos: Vector2) -> bool:
	return levels_placed.find_custom(func(item: Vector2):
		return item == Vector2(pos.x - 1, pos.y)
	) != -1
	
func _has_top_neighbour(pos: Vector2) -> bool:
	return levels_placed.find_custom(func(item: Vector2):
		return item == Vector2(pos.x, pos.y - 1)
	) != -1

func _has_bottom_neighbour(pos: Vector2) -> bool:
	return levels_placed.find_custom(func(item: Vector2):
		return item == Vector2(pos.x, pos.y + 1)
	) != -1

func _get_empty_neighbours(cell: Vector2, rows: int) -> Array[Vector2]:
	var empty_neighborous = [] as Array[Vector2]
	# right neigbour
	if cell.x + 1 < rows and not _has_right_neighbour(cell):
		empty_neighborous.push_back(Vector2(cell.x + 1, cell.y))
	# left neighbour
	if cell.x - 1 >= 0 and not _has_left_neighbour(cell):
		empty_neighborous.push_back(Vector2(cell.x - 1, cell.y))
	# top neigbour
	if cell.y - 1 >= 0 and not _has_top_neighbour(cell):
		empty_neighborous.push_back(Vector2(cell.x, cell.y - 1))
	# bottom neighbour
	if cell.y + 1 < rows and not _has_bottom_neighbour(cell):
		empty_neighborous.push_back(Vector2(cell.x, cell.y + 1))

	return empty_neighborous

func _get_number_of_rows() -> int:
	var number_of_cells := ceil(sqrt(NUMBER_OF_ROOMS)) * ceilf(sqrt(NUMBER_OF_ROOMS))
	var ratio := sqrt(number_of_cells) as int
	if ratio % 2 == 0:
		return ratio + 1
	return ratio

func _print_level() -> void:
	print_debug(levels_placed)
	pass
