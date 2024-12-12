extends Area3D

signal gate_activated(is_positive, effect_value, operation)

@export var is_positive: bool = true  # Determines if gate is positive or negative
@export var effect_value: int = 1  # The value to apply when interacting
@export var operation: String = "+"  # Mathematical operation
@export var speed: float = 6.0  # Gate movement speed

@onready var label = $Label3D
@onready var mesh_instance = $MeshInstance3D

func _process(delta):
	# Move the gate along the X-axis
	global_transform.origin.x -= speed * delta

	# Reset gate if it moves out of bounds
	if global_transform.origin.x < -10:
		randomize_gate()
		reset_gate_position()

func _ready():
	setup_gate_appearance()
	update_label()

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("gate_activated", is_positive, effect_value, operation)
		randomize_gate()
		reset_gate_position()

func setup_gate_appearance():
	var material = mesh_instance.material_override
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.material_override = material

	# Set color to blue and transparent
	material.albedo_color = Color(0, 0, 1, 0.5)  # Blue with 50% transparency
	material.transparency = true  # Enable transparency

func update_label():
	if label:
		label.text = operation + str(effect_value)

func randomize_gate():
	# Randomize gate operation and effect value
	is_positive = randi() % 2 == 0
	var operations = ["+", "*"] if is_positive else ["-", "/"]
	operation = operations[int(randi() % operations.size())]
	effect_value = int(randi() % 9 + 1)
	update_label()

func reset_gate_position():
	global_transform.origin.x += 40  # Move gate back to its starting position

func update_speed(new_speed: float):
	speed = new_speed
