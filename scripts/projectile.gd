class_name Projectile extends Node3D

var team := -1

var time_to_live_timer: Timer

var can_fly := false

var _dmg: float
var _projectile_speed: float

func _enter_tree() -> void:
	time_to_live_timer = Timer.new()
	add_child(time_to_live_timer)

func _ready() -> void:
	time_to_live_timer.one_shot = true
	time_to_live_timer.timeout.connect(func(): 
		queue_free()
	)

func shoot(ttl: float, dmg: float, projectile_speed: float, team: int) -> void:
	time_to_live_timer.wait_time = ttl
	time_to_live_timer.start()
	
	self.team = team
	_dmg = dmg
	_projectile_speed = projectile_speed

	can_fly = true

func _physics_process_child(_delta) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if can_fly:
		global_position += global_basis.z * _projectile_speed * _delta
		
	_physics_process_child(_delta)
