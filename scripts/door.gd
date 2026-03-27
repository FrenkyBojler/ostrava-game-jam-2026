class_name Door extends Node3D

@onready var closed_door := %Closed
@onready var opened_door := %Open

func opened() -> void:
	closed_door.visible = false
	opened_door.visible = true

func closed() -> void:
	closed_door.visible = true
	opened_door.visible = false
