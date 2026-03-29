extends Control

const upgrade_label := preload("res://prefabs/upgrade_label.tscn")

@onready
var container := %Container as VBoxContainer

func _ready() -> void:
	for upgrade in GlobalUpgrades.active_upgrades:
		var upgrade_label_instance := upgrade_label.instantiate() as Label
		upgrade_label_instance.text = upgrade.property + " " + str(upgrade.value)
		container.add_child(upgrade_label_instance)
	
	GlobalUpgrades.upgrade_picked.connect(func(upgrade: UpgradeResource):
		var upgrade_label_instance := upgrade_label.instantiate() as Label
		upgrade_label_instance.text = upgrade.property + " " + str(upgrade.value)
		container.add_child(upgrade_label_instance)
	)
