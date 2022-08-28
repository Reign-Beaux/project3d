extends CharacterBase

onready var animationPlayer: = $AnimationPlayer
onready var springArm: = $SpringArm

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
		springArm.rotate_x(deg2rad(event.relative.y * mouseSensitivity))
		springArm.rotation.x = clamp(springArm.rotation.x, deg2rad(-55), deg2rad(55))
	

func _physics_process(delta: float) -> void:
	var inputVector: = get_input_vector()
	var direction: = get_direction(inputVector)
	apply_movement(inputVector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	apply_controller_rotation()
	change_animation()
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, true)

func apply_controller_rotation() -> void:
	var axisVector = Vector2.ZERO
	axisVector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axisVector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axisVector.x) * controllerSensitivity)
		springArm.rotate_x(deg2rad(-axisVector.y) * controllerSensitivity)

func change_animation() -> void:
	if is_on_floor():
		if velocity.x != 0 or velocity.z != 0:
			animationPlayer.play("Run")
		else:
			animationPlayer.play("Idle")
