class_name SMGProjectile extends Projectile

func shoot(ttl: float, dmg: float, projectile_speed: float, team: int) -> void:
	time_to_live_timer.wait_time = ttl
	time_to_live_timer.start()

	self.team = team
	_dmg = dmg
	_projectile_speed = projectile_speed

	can_fly = true

func _physics_process(_delta: float) -> void:
	if can_fly:
		global_position += global_basis.z * _projectile_speed * _delta
