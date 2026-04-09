class_name PlayerState extends Node

var max_health : int

var current_health : int

var walk_speed : float

signal health_changed(current_health: int, max_health: int)

func _ready() -> void:
	_reset()

	GlobalGameState.game_reset.connect(_reset)
	GlobalUpgrades.upgrade_picked.connect(_apply_upgrade)

func _reset() -> void:
	max_health = 6
	current_health = max_health
	walk_speed = 9.0

func _apply_upgrade(upgrade: UpgradeResource) -> void:
	var prop = upgrade.property.trim_prefix("player.")
	if prop == "heal":
		change_health(upgrade.value)
	elif prop == "max_health":
		max_health += upgrade.value
		change_health(upgrade.value)

func change_health(value: int) -> void:
	current_health = min(current_health + value, max_health)
	health_changed.emit(current_health, max_health)
