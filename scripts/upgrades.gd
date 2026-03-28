class_name Upgrades extends Node

var active_upgrades: Array[UpgradeResource]

signal upgrade_picked(upgrade: UpgradeResource)

func pick_upgrade(upgrade: UpgradeResource) -> void:
	active_upgrades.push_back(upgrade)
	upgrade_picked.emit(upgrade)
