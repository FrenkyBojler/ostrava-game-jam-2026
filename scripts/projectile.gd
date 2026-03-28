class_name Projectile extends Node3D

@onready
var placeholder_bullet := %PlaceholderBullet
var time_to_live_timer: Timer

var can_fly := false

var _dmg: float
var _projectile_speed: float

func _enter_tree() -> void:
	time_to_live_timer = Timer.new()
	add_child(time_to_live_timer)

func _ready() -> void:
	placeholder_bullet.visible = false
	
	time_to_live_timer.one_shot = true
	time_to_live_timer.timeout.connect(func(): 
		queue_free()
	)

func shoot(ttl: float, dmg: float, projectile_speed: float) -> void:
	time_to_live_timer.wait_time = ttl
	time_to_live_timer.start()
	
	_dmg = dmg
	_projectile_speed = projectile_speed

	can_fly = true

func _physics_process(_delta: float) -> void:
	if can_fly:
		global_position += global_basis.z * _projectile_speed * _delta
