extends Node3D

@export var knight_scene: PackedScene  # Drag your Knight.tscn here
@export var minion_scene: PackedScene  # Drag the Skeleton_Minion.tscn here
@export var spawn_interval: float = 5.0
@export var skeleton_spawn_interval: float = 5.0
@export var max_spawn_count: int = 100
@export var spawn_height_offset: float = 2.0
@export var spawn_back_offset: float = 25.0
@export var initial_skeletons_per_wave: int = 1
@export var skeleton_wave_increase: int = 2
@export var game_over_scene: String = "res://scenes/gameover.tscn"

var current_spawn_count: int = 0
var current_knight_count: int = 1
var skeletons_per_wave: int
@onready var player_node = $"../Player"

func _ready():
	add_to_group("spawner")
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
	var remove_count = min(count, knights_in_group.size())
	for i in range(remove_count):
		var knight_to_remove = knights_in_group[i]
		knight_to_remove.queue_free()

		# Decrement counts immediately
		if current_knight_count > 0:
			current_knight_count -= 1
		if current_spawn_count > 0:
			current_spawn_count -= 1

		print("Knight removed. Current knight count: ", current_knight_count)

	_check_game_over()

func _divide_knights(factor: int):
	var knights_to_remove = max(1, int(current_knight_count / factor))
	_remove_knights(knights_to_remove)

func _spawn_knight():
	if current_spawn_count >= max_spawn_count:
		return

	if player_node == null:
		return

	var spawn_position = player_node.global_transform.origin
	spawn_position.y += current_knight_count * spawn_height_offset
	spawn_position.x -= spawn_back_offset
	spawn_position.x += randf_range(-3.0, 3.0)
	spawn_position.z += randf_range(-2.0, 2.0)

	if knight_scene:
		var knight = knight_scene.instantiate()
		knight.global_transform.origin = spawn_position
		add_child(knight)
		
		# Add the knight to the "knight" group
		knight.add_to_group("knight")

		current_spawn_count += 1
		current_knight_count += 1
		print(current_knight_count)

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
		spawn_position.x += randf_range(-3.0, 3.0)
		spawn_position.z += randf_range(-4.0, 4.0)

		if minion_scene:
			var skeleton = minion_scene.instantiate()
			skeleton.global_transform.origin = spawn_position
			add_child(skeleton)

			current_spawn_count += 1

	# Increase the number of skeletons for the next wave
	skeletons_per_wave += skeleton_wave_increase

func _check_game_over():
	if current_knight_count <= 0:
		print("Game Over!")
		_show_game_over_screen()

func _show_game_over_screen():
	if game_over_scene:
		get_tree().change_scene_to_file(game_over_scene)
	else:
		print("Error: Game Over scene not set!")