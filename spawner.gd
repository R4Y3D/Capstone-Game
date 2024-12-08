extends Node3D

@export var knight_scene: PackedScene  # Drag your Knight.tscn here
@export var mage_scene: PackedScene  # Drag the Skeleton_Mage.tscn here
@export var minion_scene: PackedScene  # Drag the Skeleton_Minion.tscn here
@export var spawn_interval: float = 5.0  # Time in seconds between spawns
@export var spawn_positions: Array = [Vector3(10, 0, 0), Vector3(-10, 0, 0)]  # Positions where skeletons can spawn
@export var spawn_randomly: bool = true  # If true, spawn randomly at positions
@export var max_spawn_count: int = 10  # Maximum number of skeletons to spawn

var current_spawn_count: int = 0  # Track how many skeletons have spawned

func _ready():
	# Start the spawn timer
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_spawn_skeleton)  # Corrected signal connection
	add_child(timer)

func _spawn_Knight(is_positive, effect_value):
	if is_positive:
		print("Duplicating knight with effect value:", effect_value)

		# Find an existing knight in the scene
		var existing_knight = get_tree().get_first_node_in_group("knight")
		if existing_knight:
			# Spawn the new knight at the existing knight's position with a slight offset
			var spawn_position = existing_knight.global_transform.origin + Vector3(2, 0, 0)  # Offset by 2 units on the X-axis
			var new_knight = knight_scene.instantiate()
			new_knight.global_transform.origin = spawn_position
			add_child(new_knight)
			print("Knight spawned at:", spawn_position)
		else:
			print("No existing knight found; cannot spawn new knight.")
	else:
		print("Removing a knight with effect value:", effect_value)
		# Remove a knight
		var knight_to_remove = get_tree().get_first_node_in_group("knight")
		if knight_to_remove:
			knight_to_remove.queue_free()
		else:
			print("No knights found to remove!")

func _spawn_skeleton():
	if current_spawn_count >= max_spawn_count:
		print("Max spawn count reached.")
		return

	var spawn_position = Vector3.ZERO
	if spawn_randomly:
		spawn_position = spawn_positions[randi() % spawn_positions.size()]
	else:
		spawn_position = spawn_positions[current_spawn_count % spawn_positions.size()]
	
	# Alternate between spawning mages and minions
	var skeleton_scene: PackedScene = mage_scene if current_spawn_count % 2 == 0 else minion_scene
	if skeleton_scene:
		var skeleton = skeleton_scene.instantiate()
		skeleton.global_transform.origin = spawn_position
		add_child(skeleton)  # Add skeleton to the spawner node or change to appropriate parent
		print("Spawned skeleton at:", spawn_position)
		
	current_spawn_count += 1
