class_name GameState extends Node

var is_paused := false

signal game_paused
signal game_unpaused

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
