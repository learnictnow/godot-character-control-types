extends CharacterBody3D

@export var sensitivity = 0.002
var last_direction = Vector3.FORWARD
var direction
var turret_last_direction = Vector3.FORWARD
@export var rotation_speed = 2

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var health_label:Label3D = $HealthLabel
@onready var camera_pivot:Marker3D = $PivotPoint

# $Camroot/h.global_transform.basis.get_euler().y
# direction = direction.rotated(Vector3.UP, h_rot).normalized()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#direction.rotated(Vector3.UP, camera_pivot.global_transform.basis.get_euler().y).normalized()
	if direction:
		last_direction = direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	$BodyMesh.rotation.y = lerp_angle($BodyMesh.rotation.y, atan2(-direction.x, -direction.z) - rotation.y, delta * rotation_speed)	
	#$BodyMesh.rotation.y = lerp_angle($BodyMesh.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)
	$CollisionShape3D.rotation.y = lerp_angle($CollisionShape3D.rotation.y, atan2(-last_direction.x, -last_direction.z), delta * rotation_speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		#camera_pivot.rotation.y -= event.relative.x * sensitivity
		rotate_y(-event.relative.x * sensitivity)
		health_label.text = str(camera_pivot.rotation)
		#last_direction = direction
		
		camera_pivot.rotation.x -= event.relative.y * sensitivity
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(90))
