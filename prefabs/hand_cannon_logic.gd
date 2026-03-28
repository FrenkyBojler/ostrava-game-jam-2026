extends GunLogic

func _shoot(gun_resource: GunResource) -> void:
	var projectile = gun_resource.projectile.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = global_rotation

	projectile.shoot(gun_resource.ttl, gun_resource.dmg, gun_resource.projectile_speed)
