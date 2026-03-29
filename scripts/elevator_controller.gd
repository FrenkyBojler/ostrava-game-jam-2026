extends Node3D

@onready
var door_1 := %Door1 as Node3D

@onready
var door_2 := %Door2 as Node3D

@onready
var original_y_pos := door_1.global_position.y

var level_started := false

func _ready() -> void:
	_hide_doors()
	
	GlobalGameState.all_levels_cleared.connect(func():
		_hide_doors()
	)
	
	GlobalGameState.player_left_start.connect(func():
		if not level_started:
			_show_doors()
			level_started = true
	)

func _hide_doors() -> void:
	door_1.global_position.y = 100
	door_2.global_position.y = 100
	
func _show_doors() -> void:
	door_1.global_position.y = original_y_pos
	door_2.global_position.y = original_y_pos
