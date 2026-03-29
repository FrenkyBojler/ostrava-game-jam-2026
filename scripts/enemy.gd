class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D

@export
var gun_resource: GunResource

@export var repath_interval := 0.5
var repath_timer := 0.0
var target_node: Node3D
var map_ready := false

@onready
var animation_player_general := %GeneralAnimPlayer as AnimationPlayer
@onready
var animation_player_movement := %MovementAnimPlayer as AnimationPlayer

@export
var max_health: float = 50
@onready
var current_health: float = max_health

var can_play_movement_anim := true
var can_move := true
var playing_death := false
var can_attack := true
var is_attacking := false

var gun: GunLogic

const DISTANCE_TO_PLAYER_BUFFER := 1.0
const MIN_ATTACK_RANGE := 2.5

signal enemy_died(who: Enemy)

@export
var projectile_placeholder_to_hide: Node3D

@onready
var projectile_placement_position: Node3D = %ProjectilePlacementPos

@export
var run_anim: String
@export
var attack_anim: String
@export
var idle_anim: String

@export
var death_sound: AudioStream
@export
var attack_sound: AudioStream

@onready
var attack_sound_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
@onready
var death_sound_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

func _ready() -> void:
	attack_sound_player.stream = attack_sound
	death_sound_player.stream = death_sound
	
	add_child(attack_sound_player)
	add_child(death_sound_player)
	
	
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_play_idle()

	map_ready = true

	gun = gun_resource.gun_logic.instantiate()
	add_child(gun)
	gun.global_position = projectile_placement_position.global_position

func _get_attack_range() -> float:
	return max(gun_resource.ttl * gun_resource.projectile_speed, MIN_ATTACK_RANGE)

func _is_in_attack_range() -> bool:
	if target_node == null:
		return false
	return global_position.distance_to(target_node.global_position) <= _get_attack_range()

func _is_melee() -> bool:
	return gun_resource.ttl * gun_resource.projectile_speed <= MIN_ATTACK_RANGE

func get_target_position_to_attack(target: Vector3) -> Vector3:
	if _is_melee():
		return target
	var direction = target.direction_to(global_position).normalized()
	# Navigate to 80% of max range so the enemy reliably ends up within attack range
	return target + direction * (_get_attack_range() * 0.8)

func set_movement_target(movement_target: Node3D):
	target_node = movement_target

func update_target_position() -> void:
	var map = navigation_agent.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, target_node.global_position)
	var move_target = safe_target
	
	if not _is_melee():
		move_target = get_target_position_to_attack(safe_target)

	navigation_agent.set_target_position(move_target)
	look_at(Vector3(target_node.global_position.x, global_position.y, target_node.global_position.z))

func _physics_process(delta):
	if playing_death or GlobalGameState.is_paused:
		return

	repath_timer -= delta

	if repath_timer <= 0.0 and map_ready:
		repath_timer = repath_interval
		update_target_position()

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	if navigation_agent.is_navigation_finished() or _is_in_attack_range():
		if can_attack and _is_in_attack_range():
			look_at(target_node.global_position)
			_play_attack()
		elif not is_attacking:
			velocity = Vector3.ZERO
			move_and_slide()
			_play_idle()
		return

	if is_attacking:
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	if not animation_player_movement.is_playing() and can_move:
		_play_run()

	if can_move:
		move_and_slide()

func take_damage(dmg: float) -> void:
	current_health -= dmg
	
	if current_health <= 0:
		die()

func die() -> void:
	can_move = false
	_play_death()

func _on_hit_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is Projectile and not playing_death:
		var projectile = area.get_parent() as Projectile
		if projectile.team != 2:
			_play_hit()
			take_damage(projectile._dmg)
			projectile.queue_free()

func _play_idle() -> void:
	if playing_death:
		return
	animation_player_movement.stop()
	animation_player_general.play(idle_anim)
	
func _play_run() -> void:
	if playing_death:
		return
	if not can_play_movement_anim or animation_player_movement.is_playing():
		return
	animation_player_general.stop()
	animation_player_movement.play(run_anim)
	
func _play_hit() -> void:
	if playing_death:
		return
	animation_player_movement.stop()
	animation_player_general.play("Hit_A")
	can_move = false
	can_play_movement_anim = false
	await get_tree().create_timer(0.4).timeout
	if playing_death:
		return
	can_play_movement_anim = true
	can_move = true

func _play_death() -> void:
	death_sound_player.play()
	playing_death = true
	can_play_movement_anim = false
	can_move = false

	animation_player_movement.stop()
	animation_player_general.play("Death_A")
	
	enemy_died.emit(self)
	await get_tree().create_timer(4).timeout
	queue_free()

func _play_attack() -> void:
	if playing_death:
		return
	attack_sound_player.play()
	can_attack = false
	is_attacking = true

	can_move = false
	can_play_movement_anim = false
	
	animation_player_movement.stop()
	animation_player_general.play(attack_anim, -1, 1 / gun_resource.rate_of_fire)
	
	await get_tree().create_timer(gun_resource.rate_of_fire * 0.5).timeout
	
	if projectile_placeholder_to_hide != null:
		projectile_placeholder_to_hide.visible = false
	_attack()
	
	await get_tree().create_timer(gun_resource.rate_of_fire * 0.5).timeout
	
	is_attacking = false
	can_move = true
	can_play_movement_anim = true
	if projectile_placeholder_to_hide != null:
		projectile_placeholder_to_hide.visible = true

	# Cooldown before allowing next attack
	await get_tree().create_timer(gun_resource.rate_of_fire).timeout
	can_attack = true

func _attack() -> void:
	if gun is WraightGunLogic:
		(gun as WraightGunLogic)._shoot_at_pos(projectile_placement_position.global_position, gun_resource, 2)
	elif gun is ThrowGunLogic:
		(gun as ThrowGunLogic)._shoot_at_direction(gun_resource, gun.global_position.direction_to(target_node.global_position), 2)
	else:
		gun._shoot(gun_resource, 2)
