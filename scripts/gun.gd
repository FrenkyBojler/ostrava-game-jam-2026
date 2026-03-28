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
@onready
var reload_timer := %ReloadTimer as Timer

var active_gun: GunResource
var active_gun_mesh: Node3D

var can_shoot := true
var is_reloading := false

var current_ammo := 0

signal ammo_updated(current: int, max: int)
signal reloading_started
signal reloading_finished

func _ready() -> void:
	placeholder_model.visible = false
	set_gun(guns[0])
	
	rate_of_fire_timer.one_shot = true
	rate_of_fire_timer.timeout.connect(func():
		can_shoot = true
	)
	
	reload_timer.one_shot = true
	reload_timer.timeout.connect(func():
		_reload()
	)

func switch_gun(index: int) -> void:
	if index < guns.size():
		set_gun(guns[index])

func shoot() -> void:
	if not can_shoot or is_reloading:
		return
	
	current_ammo -= 1
	
	ammo_updated.emit(current_ammo, active_gun.max_ammo)

	if current_ammo == 0:
		_starting_reloading()
		return

	can_shoot = false
	rate_of_fire_timer.start()
	
	animation_player.play(active_gun.anim_shoot_name)
	var projectile = projectile_scene.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.global_rotation = global_rotation
	
	projectile.shoot(active_gun.ttl, active_gun.dmg, active_gun.projectile_speed, active_gun.projectile_model)
	
func _starting_reloading() -> void:
	is_reloading = true
	reload_timer.start()
	reloading_started.emit()

func _reload() -> void:
	is_reloading = false
	current_ammo = active_gun.max_ammo
	ammo_updated.emit(current_ammo, active_gun.max_ammo)
	reloading_finished.emit()

func set_gun(gun: GunResource) -> void:
	if active_gun_mesh != null:
		active_gun_mesh.queue_free()

	active_gun = gun
	current_ammo = active_gun.max_ammo

	ammo_updated.emit(current_ammo, active_gun.max_ammo)
	
	active_gun_mesh = active_gun.model.instantiate()
	gun_model_handler.add_child(active_gun_mesh)
	
	rate_of_fire_timer.wait_time = active_gun.rate_of_fire
	reload_timer.wait_time = active_gun.reload_time
