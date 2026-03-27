extends CharacterBody3D

@export var move_speed: float = 500.0
@export var look_sensitivity: float = 0.03
@export var jump_strength: float = 8.0
@export var gravity: float = -20.0
var pitch: float = 0.0

@onready var camera := %Camera3D
@onready var hands := %Hands

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_look(delta)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Handle player movement
func handle_movement(delta: float) -> void:
	# Get input direction
	var input_direction: Vector3 = Vector3.ZERO
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	# Adjust for camera directiond
	input_direction = input_direction.normalized()
	var rotated_direction = (global_transform.basis * input_direction).normalized()

	# Apply movement
	velocity.x = rotated_direction.x * move_speed * delta
	velocity.z = rotated_direction.z * move_speed * delta
	velocity.y += gravity * delta
	
	if velocity.x != 0 or velocity.z != 0:
		hands.play_run()
	else:
		hands.play_idle()
	
	move_and_slide()

func handle_look(delta: float) -> void:
	var mouse_delta: Vector2 = Input.get_last_mouse_velocity() * look_sensitivity * delta
	pitch = clamp(pitch - mouse_delta.y, -90, 90)
	camera.rotation_degrees.x = pitch
	rotation_degrees.y -= mouse_delta.x
