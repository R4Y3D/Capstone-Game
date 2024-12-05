extends CharacterBody3D

@export var speed: float = 5.0
@export var z_min: float = -3.2  # Minimum allowed z position
@export var z_max: float = 3.4  # Maximum allowed z position

func _process(delta: float):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("up"):
		input_dir.x += 1
	if Input.is_action_pressed("down"):
		input_dir.x -= 1
	if Input.is_action_pressed("left"):
		input_dir.z -= 1
	if Input.is_action_pressed("right"):
		input_dir.z += 1

	input_dir = input_dir.normalized()

	# Move the player by updating its position
	global_transform.origin += input_dir * speed * delta

	# Restrict the z position to stay within the defined range
	global_transform.origin.z = clamp(global_transform.origin.z, z_min, z_max)

func _ready():
	add_to_group("player")
