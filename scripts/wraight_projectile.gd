extends Projectile

func shoot(ttl: float, dmg: float, projectile_speed: float) -> void:
	time_to_live_timer.wait_time = ttl
	time_to_live_timer.start()

	_dmg = dmg
