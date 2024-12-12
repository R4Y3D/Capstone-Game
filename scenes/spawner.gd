extends Node3D

@export var knight_scene: PackedScene  # Drag your Knight.tscn here
@export var minion_scene: PackedScene  # Drag the Skeleton_Minion.tscn here
@export var spawn_interval: float = 5.0  # Time in seconds between knight spawns
@export var skeleton_spawn_interval: float = 5.0  # Time in seconds between skeleton spawn waves
@export var max_spawn_count: int = 100  # Maximum number of spawns allowed
@export var spawn_height_offset: float = 2.0  # Height above player for stacking knights
@export var spawn_back_offset: float = 25.0  # Distance behind the player (-X direction)
@export var initial_skeletons_per_wave: int = 1  # Number of skeletons to spawn initially
@export var skeleton_wave_increase: int = 1  # Number of additional skeletons per wave

var current_spawn_count: int = 0  # Track total active spawns
var current_knight_count: int = 0  # Track knight count separately
var skeletons_per_wave: int  # Number of skeletons to spawn in the current wave
@onready var player_node = $"../Player"  # Adjust to the actual path of your player node

func _ready():
	skeletons_per_wave = initial_skeletons_per_wave

	# Start the skeleton spawn timer
	var skeleton_timer = Timer.new()
	skeleton_timer.wait_time = skeleton_spawn_interval
	skeleton_timer.one_shot = false
	skeleton_timer.autostart = true
	skeleton_timer.timeout.connect(_spawn_skeleton_wave)
	add_child(skeleton_timer)

func process_interaction(is_positive: bool, effect_value: int, operation: String):
	if is_positive:
		match operation:
			"+":
				_add_knights(effect_value)
			"*":
				_multiply_knights(effect_value)
	else:
		match operation:
			"-":
				_remove_knights(effect_value)
			"/":
				_divide_knights(effect_value)

func _add_knights(count: int):
	for i in range(count):
		_spawn_knight()

func _multiply_knights(factor: int):
	var spawn_count = current_knight_count * (factor - 1)
	for i in range(spawn_count):
		_spawn_knight()

func _remove_knights(count: int):
	var knights_in_group = get_tree().get_nodes_in_group("knight")
	for i in range(min(count, knights_in_group.size())):
		if knights_in_group.size() > 0:
			var knight_to_remove = knights_in_group[0]
			knight_to_remove.queue_free()
			knights_in_group.remove_at(0)
			current_knight_count -= 1
			current_spawn_count -= 1

func _divide_knights(factor: int):
	var knights_to_remove = max(1, int(current_knight_count / factor))
	_remove_knights(knights_to_remove)

func _spawn_knight():
	if current_spawn_count >= max_spawn_count:
		print("Max spawn count reached.")
		return

	if player_node == null:
		print("Error: Player node not found.")
		return

	# Determine spawn position based on the player's position
	var spawn_position = player_node.global_transform.origin  # Start at the player's position

	# Adjust spawn position: stack above and move backward in the -X direction
	spawn_position.y += current_knight_count * spawn_height_offset  # Stack knights above the player
	spawn_position.x -= spawn_back_offset  # Move backward relative to the player
	spawn_position.x += randf_range(-3.0, 3.0)  # Randomize horizontal position (left/right)
	spawn_position.z += randf_range(-2.0, 2.0)  # Randomize depth (forward/backward)

	# Instantiate the knight
	if knight_scene:
		var knight = knight_scene.instantiate()
		knight.global_transform.origin = spawn_position
		add_child(knight)
		print("Spawned knight at:", spawn_position)

		current_spawn_count += 1
		current_knight_count += 1

func _spawn_skeleton_wave():
	if current_spawn_count >= max_spawn_count:
		print("Max spawn count reached.")
		return

	if player_node == null:
		print("Error: Player node not found.")
		return

	# Spawn multiple skeletons in this wave
	for i in range(skeletons_per_wave):
		var spawn_position = player_node.global_transform.origin
		spawn_position.x += randf_range(-3.0, 3.0)  # Randomize horizontal position
		spawn_position.z += randf_range(-4.0, 4.0)  # Randomize depth

		if minion_scene:
			var skeleton = minion_scene.instantiate()
			skeleton.global_transform.origin = spawn_position
			add_child(skeleton)
			print("Spawned skeleton at:", spawn_position)

			current_spawn_count += 1

	# Increase the number of skeletons for the next wave
	skeletons_per_wave += skeleton_wave_increase
