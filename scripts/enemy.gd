class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D

@export var repath_interval := 0.5
var repath_timer := 0.0
var target_node: Node3D
var map_ready := false

@export
var max_health: float = 50

@onready
var current_health: float = max_health

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	$AnimationPlayer.play("Running_A")

	NavigationServer3D.map_changed.connect(func(cosi: RID): 
		map_ready = true
	)

func set_movement_target(movement_target: Node3D):
	target_node = movement_target
	
func update_target_position() -> void:
	var map = navigation_agent.get_navigation_map()
	var safe_target = NavigationServer3D.map_get_closest_point(map, target_node.global_position)
	navigation_agent.set_target_position(safe_target)
	look_at(safe_target)

func _physics_process(delta):
	repath_timer -= delta

	if repath_timer <= 0.0 and map_ready:
		repath_timer = repath_interval
		update_target_position()
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func take_damage(dmg: float) -> void:
	current_health -= dmg
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_hit_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is Projectile:
		var projectile = area.get_parent() as Projectile
		take_damage(projectile.dmg)
		projectile.queue_free()
