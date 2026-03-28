class_name Player extends PlayerCharacter

@onready var hands := %Hands as Hands
@onready var enemy_check_raycast := %EnemyCheck as RayCast3D
@onready var my_crosshair := %MyCrosshair as Crosshair
@onready var hit_texture := %HitTexture as HitRect

var is_reloading := false

const MAX_HEALTH := 100.0

@onready
var current_health := MAX_HEALTH

var has_dashed_recently := false

var minimap: MiniMap
var current_level_pos: Vector2

func setup(minimap: MiniMap) -> void:
	self.minimap = minimap

func _ready_child() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	hands.gun.ammo_updated.connect(func(current_ammo: int, max_ammo: int):
		%CurrentAmmoLabel.text = str(current_ammo) + "/" + str(max_ammo)
	)
	
	hands.gun.reloading_started.connect(func():
		is_reloading = true
		%ReloadingLabel.visible = true
		my_crosshair.switch_to_reloading()
	)
	
	hands.gun.reloading_finished.connect(func():
		is_reloading = false
		%ReloadingLabel.visible = false
		my_crosshair.switch_to_normal()
	)

func _process_child(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
	if Input.is_action_just_pressed("reload") and not is_reloading:
		hands.gun._starting_reloading()
	
	_check_crosshair()
	
	minimap.update_player(global_position, $CameraHolder.global_rotation.y)


func _check_crosshair() -> void:
	if is_reloading:
		return
	if enemy_check_raycast.is_colliding():
		var distance = enemy_check_raycast.get_collision_point().distance_to(global_position)
		if abs(distance) <= hands.gun.active_gun.ttl * hands.gun.active_gun.projectile_speed:
			my_crosshair.switch_to_enemy_close()
		else:
			my_crosshair.switch_to_enemy_far()
	else:
		my_crosshair.switch_to_normal()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.as_text_physical_keycode() == "1":
			hands.gun.switch_gun(0)
		if key_event.as_text_physical_keycode() == "2":
			hands.gun.switch_gun(1)
		if key_event.as_text_physical_keycode() == "3":
			hands.gun.switch_gun(2)
		if key_event.as_text_physical_keycode() == "4":
			hands.gun.switch_gun(3)
	
func shoot() -> void:
	hands.gun.shoot()

func _on_hit_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is Projectile:
		var projectile = area.get_parent() as Projectile
		if projectile.team != 1:
			_play_hit()
			_take_damage(projectile._dmg)
			projectile.queue_free()
	if area.get_parent() is Door and not (area.get_parent() as Door).broken:
		%BreakDoorLabel.visible = true
	if area.is_in_group("BreakDoor") and has_dashed_recently and not (area.get_parent() as Door).broken:
		(area.get_parent() as Door).break_door(velocity)

func _take_damage(dmg: float) -> void:
	current_health -= dmg
	%HealthLabel.text = str(current_health)
	
	if current_health <= 0:
		call_deferred("_death")

func _play_hit() -> void:
	hit_texture.play_hit()
	
func _death() -> void:
	get_tree().reload_current_scene()

func _on_hit_area_area_exited(area: Area3D) -> void:
	if area.get_parent() is Door:
		%BreakDoorLabel.visible = false

func _on_dash_state_transitioned(caller: Node, value: String) -> void:
	has_dashed_recently = true
	await get_tree().create_timer(0.5).timeout
	has_dashed_recently = false
