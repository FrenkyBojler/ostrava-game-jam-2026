class_name Crosshair extends Control

@onready
var texture := %CrosshairTexture

@export
var normal_crosshair_texture: CompressedTexture2D
@export
var enemy_far_crosshair_texture: CompressedTexture2D
@export
var enemy_close_crosshair_texture: CompressedTexture2D

func _ready() -> void:
	switch_to_normal()

func switch_to_enemy_far() -> void:
	texture.texture = enemy_far_crosshair_texture
	
func switch_to_enemy_close() -> void:
	texture.texture = enemy_close_crosshair_texture
	
func switch_to_normal() -> void:
	texture.texture = normal_crosshair_texture
