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

signal enemy_died(who: Enemy)

@onready
var projectile_placement_position: Node3D = %ProjectilePlacementPos

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_play_idle()

	map_ready = true

	gun = gun_resource.gun_logic.instantiate()
	add_child(gun)

func get_target_position_to_attack(target: Vector3) -> Vector3:
	var direction = target.direction_to(global_position).normalized()
	return target - (direction * gun_resource.ttl * gun_resource.projectile_speed) + (direction * DISTANCE_TO_PLAYER_BUFFER)

func set_movement_target(movement_target: Node3D):
	target_node = movement_target

func update_target_position() -> void:
	var map = navigation_agent.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, target_node.global_position)
	var move_target = safe_target
	
	if can_attack:
		move_target = get_target_position_to_attack(safe_target)

	navigation_agent.set_target_position(move_target)
	look_at(move_target)

func _physics_process(delta):
	if playing_death:
		return

	repath_timer -= delta

	if repath_timer <= 0.0 and map_ready:
		repath_timer = repath_interval
		update_target_position()

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	if navigation_agent.is_navigation_finished():
		if can_attack:
			_play_attack()
		elif not is_attacking:
			_play_idle()
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
	animation_player_movement.stop()
	animation_player_general.play("Idle_A")
	
func _play_run() -> void:
	if not can_play_movement_anim:
		return
	animation_player_movement.play("Jump_Full_Short")
	animation_player_general.stop()
	
func _play_hit() -> void:
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
	playing_death = true
	can_play_movement_anim = false
	can_move = false

	animation_player_movement.stop()
	animation_player_general.play("Death_A")
	
	enemy_died.emit(self)
	await get_tree().create_timer(4).timeout
	queue_free()

func _play_attack() -> void:
	can_attack = false
	is_attacking = true

	can_move = false
	can_play_movement_anim = false
	
	animation_player_movement.stop()
	animation_player_general.play("Throw")
	
	await get_tree().create_timer(0.7).timeout
	_attack()
	await get_tree().create_timer(0.5).timeout
	
	is_attacking = false
	can_move = true
	can_play_movement_anim = true
	can_attack = true

func _attack() -> void:
	if gun is WraightGunLogic:
		(gun as WraightGunLogic)._shoot_at_pos(projectile_placement_position.global_position, gun_resource, 2)
