class_name Gun extends Node3D

@export
var guns: Array[GunResource]

@onready
var placeholder_model := %PlaceholderModel
@onready
var gun_model_handler := %GunModelHandler
@export
var animation_player: AnimationPlayer
@onready
var rate_of_fire_timer := %RateOfFireTimer as Timer
@onready
var reload_timer := %ReloadTimer as Timer

var active_gun: GunResource
var active_gun_logic: GunLogic

var can_shoot := true
var is_reloading := false

var current_ammo := 0

signal ammo_updated(current: int, max: int)
signal reloading_started
signal reloading_finished

func _ready() -> void:
	#placeholder_model.visible = false
	set_gun(guns[0])
	
	rate_of_fire_timer.one_shot = true
	rate_of_fire_timer.timeout.connect(func():
		can_shoot = true
	)
	
	reload_timer.one_shot = true
	reload_timer.timeout.connect(func():
		_reload()
	)
	
	play_idle()

func switch_gun(index: int) -> void:
	if index < guns.size():
		set_gun(guns[index])

func play_idle() -> void:
	animation_player.play("idle")

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
	
	animation_player.play("fire", -1, 1 / active_gun.rate_of_fire)
	active_gun_logic._shoot(active_gun, 1)
	await get_tree().create_timer(active_gun.rate_of_fire).timeout
	play_idle()

func _starting_reloading() -> void:
	is_reloading = true
	animation_player.play("reload", -1, 1 / active_gun.reload_time)
	reload_timer.start()
	reloading_started.emit()

func _reload() -> void:
	is_reloading = false
	current_ammo = active_gun.max_ammo
	ammo_updated.emit(current_ammo, active_gun.max_ammo)
	reloading_finished.emit()

func set_gun(gun: GunResource) -> void:
	if active_gun_logic != null:
		active_gun_logic.queue_free()

	active_gun = gun
	current_ammo = active_gun.max_ammo

	ammo_updated.emit(current_ammo, active_gun.max_ammo)
	
	active_gun_logic = active_gun.gun_logic.instantiate()
	placeholder_model.add_child(active_gun_logic)
	
	rate_of_fire_timer.wait_time = active_gun.rate_of_fire
	reload_timer.wait_time = active_gun.reload_time
