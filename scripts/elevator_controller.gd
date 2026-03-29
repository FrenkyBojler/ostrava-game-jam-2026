extends Node3D

@onready
var door_1 := %Door1 as Node3D

@onready
var door_2 := %Door2 as Node3D

func _ready() -> void:
	GlobalGameState.all_levels_cleared.connect(func():
		_hide_doors()
	)

func _hide_doors() -> void:
	door_1.queue_free()
	door_2.queue_free()
