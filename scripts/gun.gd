class_name Gun extends Node3D

@export
var guns: Array[GunResource]

@onready
var placeholder_model := %PlaceholderModel
@onready
var gun_model_handler := %GunModelHandler
@onready
var animation_player := %AnimationPlayer

var active_gun: GunResource
var active_gun_mesh: Node3D

func _ready() -> void:
	placeholder_model.visible = false
	set_gun(guns[0])

func shoot() -> void:
	animation_player.play(active_gun.anim_shoot_name)

func set_gun(gun: GunResource) -> void:
	if active_gun_mesh != null:
		active_gun_mesh.queue_free()
	
	active_gun = gun
	active_gun_mesh = active_gun.model.instantiate()
	gun_model_handler.add_child(active_gun_mesh)
