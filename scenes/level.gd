extends Node3D

@export var modules: Array[PackedScene] = []
@export var module_base_offsets: Array[float] = [16.0, 20.0, 20.0, 20.0]  # Base offsets for each module type
@export var iterations_per_module: Array[int] = [5, 5, 2, 5]  # Iterations for each module type

# Speed progression variables
@export var initial_speed: float = 5.0  # Starting speed
@export var max_speed: float = 20.0  # Maximum speed cap
@export var acceleration: float = 0.0  # How quickly speed increases

var amnt = 30
var rng = RandomNumberGenerator.new()
var current_module_index = -1
var current_module_iteration = 0

# Create a copy of base offsets to allow independent modification
var module_offsets: Array[float] = []

# Speed tracking
var current_speed: float = initial_speed
var elapsed_time: float = 0.0

func _ready():
	# Create a deep copy of base offsets
	module_offsets = module_base_offsets.duplicate()

	print("Modules count: ", modules.size())
	print("Initial Module Offsets: ", module_offsets)

	# Ensure module_offsets matches modules array size
	while module_offsets.size() < modules.size():
		module_offsets.append(module_offsets[0])  # Default to first offset if not specified

	# Ensure iterations_per_module matches modules array size
	while iterations_per_module.size() < modules.size():
		iterations_per_module.append(iterations_per_module[0])  # Default iteration count

	for n in amnt:
		spawnModule(n * module_offsets[0])  # Use first offset initially

func _process(delta):
	# Increase elapsed time
	elapsed_time += delta

	# Gradually increase speed
	current_speed = min(
		initial_speed + (acceleration * elapsed_time), 
		max_speed
	)

func get_next_module_offset() -> float:
	# Choose a new module index if we've exhausted current iterations
	if current_module_iteration >= iterations_per_module[current_module_index]:
		rng.randomize()
		current_module_index = rng.randi_range(0, modules.size() - 1)
		current_module_iteration = 0
		print("Switched to Module Index: ", current_module_index)
	
	current_module_iteration += 1

	# Return the offset for the current module type
	print("Next Module Offset for Index ", current_module_index, ": ", module_offsets[current_module_index])
	return module_offsets[current_module_index]

func spawnModule(n):
	if current_module_index == -1:
		rng.randomize()
		current_module_index = rng.randi_range(0, modules.size() - 1)
	
	var instance = modules[current_module_index].instantiate()
	instance.position.x = n
	add_child(instance)
	
	# Pass current speed to the spawned module
	if instance.has_method("update_speed"):
		instance.update_speed(current_speed)
	
	# Return the next module's offset for subsequent spawning
	return get_next_module_offset()

# Method to get current speed for other scripts if needed
func get_current_speed() -> float:
	return current_speed
