extends GunLogic

func _shoot(gun_resource: GunResource, team: int) -> void:
	_spawn_projectile(gun_resource, team)
	await get_tree().create_timer(0.1).timeout
	_spawn_projectile(gun_resource, team)
	await get_tree().create_timer(0.1).timeout
	_spawn_projectile(gun_resource, team)

func _spawn_projectile(gun_resource: GunResource, team: int) -> void:
	var projectile = gun_resource.projectile.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = get_parent().get_parent().global_rotation

	projectile.shoot(gun_resource.ttl, gun_resource.dmg, gun_resource.projectile_speed, team)
