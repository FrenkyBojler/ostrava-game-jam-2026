class_name Upgrades extends Node

var active_upgrades: Array[UpgradeResource]

signal upgrade_picked(upgrade: UpgradeResource)
signal upgrades_cleared

func _ready() -> void:
	GlobalGameState.player_died.connect(func():
		_reset_upgrades()
	)

func pick_upgrade(upgrade: UpgradeResource) -> void:
	active_upgrades.push_back(upgrade)
	upgrade_picked.emit(upgrade)
	
func _reset_upgrades() -> void:
	active_upgrades = []
	upgrades_cleared.emit()
