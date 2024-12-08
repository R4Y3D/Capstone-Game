extends Node3D

@export var gate_scene: PackedScene  # Drag your Gate.tscn here
@export var spawn_distance: float = 40.0  # Distance from the player
@export var gate_spacing: float = 3.0  # Distance between the gates
@export var gate_speed: float = 6.0  # Initial speed for the gates
@export var speed_increase: float = 2.0  # Speed increment
@export var max_speed: float = 50.0  # Maximum speed the gates can reach
@export var speed_increase_interval: float = 5.0  # Time (in seconds) between speed increases

@onready var spawner: Node3D = $"../Spawner"

func _ready():
	spawn_gates()  # Spawn the initial gates
	start_speed_timer()  # Start the timer to increase speed

func spawn_gates():
	# Spawn a positive gate (green gate)
	var positive_gate = gate_scene.instantiate()
	positive_gate.global_transform.origin = Vector3(spawn_distance, 1.0, gate_spacing)
	positive_gate.is_positive = true
	positive_gate.speed = gate_speed  # Pass the current global speed
	add_child(positive_gate)
	positive_gate.gate_activated.connect(_on_positive_gate_activated)

	# Spawn a negative gate (red gate)
	var negative_gate = gate_scene.instantiate()
	negative_gate.global_transform.origin = Vector3(spawn_distance, 1.0, -gate_spacing)
	negative_gate.is_positive = false
	negative_gate.speed = gate_speed  # Pass the current global speed
	add_child(negative_gate)
	negative_gate.gate_activated.connect(_on_negative_gate_activated)

	# Link the two gates as partners
	positive_gate.partner_gate = negative_gate
	negative_gate.partner_gate = positive_gate

func _on_positive_gate_activated(is_positive, effect_value):
	if spawner:
		spawner._spawn_Knight(true, effect_value)

func _on_negative_gate_activated(is_positive, effect_value):
	if spawner:
		spawner._spawn_Knight(false, effect_value)

func start_speed_timer():
	# Create a timer to periodically increase speed
	var timer = Timer.new()
	timer.wait_time = speed_increase_interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(self._increase_speed)  # Correct signal connection
	add_child(timer)

func _increase_speed():
	if gate_speed < max_speed:
		gate_speed += speed_increase
		print("Gate speed increased to:", gate_speed)

		# Update the speed for all existing gates
		for child in get_children():
			if child is Area3D and child.has_method("update_speed"):
				child.update_speed(gate_speed)
