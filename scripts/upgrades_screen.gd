extends Control

const upgrade_prefab = preload("res://prefabs/upgrade.tscn")

@onready
var upgrades_container: HBoxContainer = %UpgradesContainer

func _ready() -> void:
	GlobalUpgrades.upgrade_picked.connect(func(upgrade: UpgradeResource):
		queue_free()
	)
	
	var upgrades := UpgradeResource.generate_upgrades(3)
	for upgrade in upgrades:
		var upgrade_instance := upgrade_prefab.instantiate() as Upgrade
		upgrade_instance.upgrade_res = upgrade
		upgrades_container.add_child(upgrade_instance)
