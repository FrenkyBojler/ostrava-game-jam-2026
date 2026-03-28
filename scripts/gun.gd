class_name Gun extends Node3D

@export
var guns: Array[GunResource]

@export
var projectile_scene: PackedScene

@onready
var placeholder_model := %PlaceholderModel
@onready
var gun_model_handler := %GunModelHandler
@onready
var animation_player := %AnimationPlayer
@onready
var rate_of_fire_timer := %RateOfFireTimer as Timer

var active_gun: GunResource
var active_gun_mesh: Node3D

var can_shoot := true

func _ready() -> void:
	placeholder_model.visible = false
	set_gun(guns[0])
	
	rate_of_fire_timer.one_shot = true
	rate_of_fire_timer.timeout.connect(func():
		can_shoot = true
	)

func shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	rate_of_fire_timer.start()
	
	animation_player.play(active_gun.anim_shoot_name)
	var projectile = projectile_scene.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = global_rotation
	
	projectile.shoot(active_gun.ttl, active_gun.dmg, active_gun.projectile_model)
	
func set_gun(gun: GunResource) -> void:
	if active_gun_mesh != null:
		active_gun_mesh.queue_free()

	active_gun = gun
	active_gun_mesh = active_gun.model.instantiate()
	gun_model_handler.add_child(active_gun_mesh)
	
	rate_of_fire_timer.wait_time = active_gun.rate_of_fire
