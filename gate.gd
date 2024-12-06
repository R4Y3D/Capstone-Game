extends Area3D

signal gate_activated(is_positive, effect_value)

@export var is_positive: bool = true  # Determines if gate is positive (green) or negative (red)
@export var effect_value: int = 1  # The value to apply when interacting
@export var speed: float = 6.0  # Gate movement speed
var partner_gate: Area3D  # Reference to the partner gate

func _process(delta):
	# Move the gate along the X-axis
	global_transform.origin.x -= speed * delta

	# Reset gate if it moves out of bounds
	if global_transform.origin.x < -10:
		reset_both_gates()

func _ready():
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.material_override
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.material_override = material

	# Set color based on gate type
	if is_positive:
		material.albedo_color = Color(0, 1, 0)  # Green for positive
	else:
		material.albedo_color = Color(1, 0, 0)  # Red for negative

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("gate_activated", is_positive, effect_value)
		reset_both_gates()

func reset_both_gates():
	if partner_gate != null:
		var swap = randi() % 2 == 0  # 50% chance to swap positions
		if swap:
			var temp_z = global_transform.origin.z
			global_transform.origin.z = partner_gate.global_transform.origin.z
			partner_gate.global_transform.origin.z = temp_z
		partner_gate.reset_gate_position()
	reset_gate_position()

func reset_gate_position():
	global_transform.origin.x += 40  # Move gate back to its starting position
