extends Node3D

@export var gate_scene: PackedScene  # Gate scene resource
@export var spawn_distance: float = 40.0  # Distance from the player
@export var gate_spacing: float = 3.0  # Distance between gates
@export var gate_speed: float = 6.0  # Initial gate speed
@export var speed_increase: float = 0.5  # Speed increment per interval
@export var max_speed: float = 50.0  # Maximum speed cap
@export var speed_increase_interval: float = 5.0  # Interval for speed increase (seconds)

@onready var spawner: Node3D = $"../Spawner"  # Reference to spawner script

func _ready():
	start_speed_timer()  # Setup speed adjustment timer
	spawn_gates()  # Initialize first gates

func spawn_gates():
	# Randomize which side will be positive
	var is_left_positive = randi() % 2 == 0

	# Generate random operations and values
	var increase_ops = ["+", "*"]
	var decrease_ops = ["-", "/"]

	var increase_op = increase_ops[randi() % increase_ops.size()]
	var decrease_op = decrease_ops[randi() % decrease_ops.size()]

	var increase_value = randi() % 5 + 1
	var decrease_value = randi() % 5 + 1

	# Instantiate gates
	var left_gate = gate_scene.instantiate()
	var right_gate = gate_scene.instantiate()

	# Assign operations and positions based on randomization
	if is_left_positive:
		left_gate.operation = increase_op
		left_gate.effect_value = increase_value
		left_gate.is_positive = true

		right_gate.operation = decrease_op
		right_gate.effect_value = decrease_value
		right_gate.is_positive = false
	else:
		left_gate.operation = decrease_op
		left_gate.effect_value = decrease_value
		left_gate.is_positive = false

		right_gate.operation = increase_op
		right_gate.effect_value = increase_value
		right_gate.is_positive = true

	# Set gate positions
	left_gate.global_transform.origin = Vector3(spawn_distance, 1.0, gate_spacing)
	right_gate.global_transform.origin = Vector3(spawn_distance, 1.0, -gate_spacing)

	# Set gate speeds
	left_gate.speed = gate_speed
	right_gate.speed = gate_speed

	# Add gates to the scene
	add_child(left_gate)
	add_child(right_gate)

	# Connect gate signals
	left_gate.connect("gate_activated", Callable(self, "_on_gate_activated"))
	right_gate.connect("gate_activated", Callable(self, "_on_gate_activated"))

func _on_gate_activated(is_positive: bool, effect_value: int, operation: String):
	if spawner:
		spawner.process_interaction(is_positive, effect_value, operation)

func start_speed_timer():
	# Timer setup for speed progression
	var timer = Timer.new()
	timer.wait_time = speed_increase_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(self._increase_speed)
	add_child(timer)

func _increase_speed():
	if gate_speed < max_speed:
		gate_speed += speed_increase
		for child in get_children():
			if child.has_method("update_speed"):
				child.update_speed(gate_speed)
