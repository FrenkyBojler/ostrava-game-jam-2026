class_name GameState extends Node

const BASE_LEVELS_COUNT := 3

var is_paused := false

signal game_paused
signal game_unpaused
signal all_levels_cleared
signal player_died
signal player_left_start
signal player_health_changed(current: int, max: int)

var levels_cleared := 0
var difficulty_multipler := 1.0
var level := 1

var player_max_health := 4
var player_current_health := 1

func get_level_count() -> int:
	return ceil(difficulty_multipler * BASE_LEVELS_COUNT)

func _ready() -> void:
	GlobalUpgrades.upgrade_picked.connect(func(upgrade: UpgradeResource):
		unpause_game()
	)

func pause_game() -> void:
	print_debug("Game Paused")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_paused = true
	game_paused.emit()

func unpause_game() -> void:
	print_debug("Game Unpaused")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_paused = false
	game_unpaused.emit()

func level_cleared() -> void:
	levels_cleared += 1
	
	if levels_cleared == get_level_count() - 1:
		all_levels_cleared.emit()

func death() -> void:
	difficulty_multipler = 1
	player_died.emit()
	levels_cleared = 0
	level = 1
	
func finish_level() -> void:
	if levels_cleared != get_level_count() - 1:
		return

	levels_cleared = 0
	difficulty_multipler += 0.5
	level += 1
	get_tree().reload_current_scene()
