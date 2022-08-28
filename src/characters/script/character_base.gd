extends KinematicBody

class_name CharacterBase

export var maxSpeed: = 10.0
export var gravity: = -40.0
export var acceleration: = 70.0
export var friction: = 60.0
export var airFriction: = 10.0
export var jumpImpulse: = 20.0
export var mouseSensitivity: = .1
export var controllerSensitivity: = 3.0

var velocity: = Vector3.ZERO
var snapVector: = Vector3.ZERO

func get_input_vector() -> Vector3:
	var inputVector = Vector3.ZERO
	inputVector.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	inputVector.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	return inputVector.normalized() if inputVector.length() > 1 else inputVector

func get_direction(inputVector: Vector3) -> Vector3:
	return (inputVector.x * transform.basis.x) + (inputVector.z * transform.basis.z)

func apply_movement(inputVector: Vector3, direction: Vector3, delta: float) -> void:
	if direction == Vector3.ZERO: return
	
	velocity.x = velocity.move_toward(direction * maxSpeed, acceleration * delta).x
	velocity.z = velocity.move_toward(direction * maxSpeed, acceleration * delta).z
	

func apply_friction(direction: Vector3, delta: float) -> void:
	if direction != Vector3.ZERO: return
	
	if is_on_floor():
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	else:
		velocity.x = velocity.move_toward(Vector3.ZERO, airFriction * delta).x
		velocity.z = velocity.move_toward(Vector3.ZERO, airFriction * delta).z

func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jumpImpulse)

func update_snap_vector() -> void:
	snapVector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snapVector = Vector3.ZERO
		velocity.y = jumpImpulse
	if Input.is_action_just_released("jump") and velocity.y > jumpImpulse / 2:
		velocity.y = jumpImpulse / 2
