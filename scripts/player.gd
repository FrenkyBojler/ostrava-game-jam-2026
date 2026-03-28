extends PlayerCharacter

@onready var hands := %Hands as Hands

func _ready_child() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process_child(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func shoot() -> void:
	hands.gun.shoot()
