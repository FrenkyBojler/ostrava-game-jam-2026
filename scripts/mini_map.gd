class_name MiniMap extends Control

const visited_tile_texture = preload("res://assets/textures/visited.png")
const unvisited_tile_texture = preload("res://assets/textures/unvisited.png")
const empty_tile_texture = preload("res://assets/textures/empty.png")
const start_texture = preload("res://assets/textures/start.png")

var grid_rows: int
var cell_world_size: float
var levels: Array[Vector2]
var visited_cells: Array[Vector2]
var tiles: Array # 2D array [y][x] of TextureRect

@onready
var player_icon := %PlayerIcon

func _ready() -> void:
	await get_tree().process_frame
	player_icon.pivot_offset = player_icon.size / 2.0

func setup(rows: int, cell_size: float, level_positions: Array[Vector2]) -> void:
	grid_rows = rows
	cell_world_size = cell_size
	levels = level_positions
	visited_cells = []

	# Clean up old grid tiles
	for child in get_children():
		if child != %Background and child != player_icon:
			child.queue_free()

	var tile_pixel_size = size / Vector2(rows, rows)
	var center = Vector2((rows - 1) / 2, (rows - 1) / 2)

	tiles = []
	for y in rows:
		var row = []
		for x in rows:
			var tile = TextureRect.new()
			tile.position = Vector2(x * tile_pixel_size.x, y * tile_pixel_size.y)
			tile.size = tile_pixel_size
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_SCALE
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE

			var grid_pos = Vector2(x, y)
			if grid_pos == center:
				tile.texture = start_texture
			elif levels.has(grid_pos):
				tile.texture = unvisited_tile_texture
			else:
				tile.texture = empty_tile_texture

			add_child(tile)
			move_child(tile, player_icon.get_index())
			row.append(tile)
		tiles.append(row)

func update_player(player_global_pos: Vector3, camera_y_rotation: float) -> void:
	if grid_rows == 0 or cell_world_size == 0.0:
		return

	# Level origins are at pos * cell_world_size, so world grid starts at -cell_world_size/2
	var half_cell = cell_world_size / 2.0
	var total_world = grid_rows * cell_world_size
	var world_2d = Vector2(player_global_pos.x + half_cell, player_global_pos.z + half_cell)
	var minimap_pos = (world_2d / total_world) * size

	player_icon.position = minimap_pos - player_icon.size / 2.0
	player_icon.rotation = -camera_y_rotation

	# Mark current cell as visited
	var cell_x = int(world_2d.x / cell_world_size)
	var cell_y = int(world_2d.y / cell_world_size)
	var cell = Vector2(cell_x, cell_y)
	if levels.has(cell) and not visited_cells.has(cell):
		visited_cells.append(cell)
		var center = Vector2((grid_rows - 1) / 2, (grid_rows - 1) / 2)
		if cell != center and cell_y >= 0 and cell_y < grid_rows and cell_x >= 0 and cell_x < grid_rows:
			tiles[cell_y][cell_x].texture = visited_tile_texture
