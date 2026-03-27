class_name Hands extends Node3D

@onready var anim_player := %AnimationPlayer

func _ready() -> void:
	play_idle()

func play_run() -> void:
	anim_player.play("Run")

func play_idle() -> void:
	anim_player.play("Idle")
