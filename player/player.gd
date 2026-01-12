extends CharacterBody3D

@export var TILT_LOWER_LIMIT := deg_to_rad(-90)
@export var JUMP_VELOCITY : float = 4.5
@export var SPEED : float = 10.0
@export var TILT_UPPER_LIMIT := deg_to_rad(90)
@export var CAMERA_CONTROLLER : Node3D
@export var MOUSE_SENTIVITY : float = 0.5
@export var ANIMATIONPLAYER : AnimationPlayer
@export_range(5, 10, 0.1) var CORUCH_SPEED : float = 8.0
@export var CROUCH_SHAPECAST : Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _mouse_rotation : Vector3
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _is_crouching : bool = false

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "CROUCH":
		_is_crouching = !_is_crouching

func _toggle_crouch():
	if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATIONPLAYER.play("CROUCH", -1, -CORUCH_SPEED, true)
		print("UNCROUCH")
	elif _is_crouching == false:
		ANIMATIONPLAYER.play("CROUCH", -1, CORUCH_SPEED)
		print("CROUCH")

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	_rotation_input = 0.0
	_tilt_input = 0.0
	global_transform.basis = Basis.from_euler(_player_rotation)

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENTIVITY
		_tilt_input = -event.relative.y * MOUSE_SENTIVITY
		print(Vector2(_rotation_input, _tilt_input))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("crouch") and is_on_floor():
		_toggle_crouch()
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUCH_SHAPECAST.add_exception($".")

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	_update_camera(delta)

	if Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == false:
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
