class_name ThrowGunLogic extends GunLogic

func _shoot_at_direction(gun_resource: GunResource, at_direction: Vector3, team: int) -> void:
	var projectile = gun_resource.projectile.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = global_rotation
	
	projectile.look_at(at_direction)
	projectile.shoot_at_direction(gun_resource.ttl, gun_resource.dmg, gun_resource.projectile_speed, at_direction, team)
