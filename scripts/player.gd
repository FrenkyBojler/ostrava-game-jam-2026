extends PlayerCharacter

@onready var hands := %Hands as Hands

func _ready_child() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process_child(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.as_text_physical_keycode() == "1":
			print_debug("Tady")
			hands.gun.switch_gun(0)
		if key_event.as_text_physical_keycode() == "2":
			print_debug("Tady 2")
			hands.gun.switch_gun(1)
		if key_event.as_text_physical_keycode() == "3":
			hands.gun.switch_gun(2)
		if key_event.as_text_physical_keycode() == "4":
			hands.gun.switch_gun(3)
	

func shoot() -> void:
	hands.gun.shoot()
