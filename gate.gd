extends Area3D

@export var is_positive: bool = true  # Determines if the gate is positive or negative
@export var effect_value: int = 1  # The effect value (e.g., +1, *2, -1, /2)
@export var speed: float = 5.0  # Default speed, will be overridden dynamically
var partner_gate: Area3D  # Reference to the partner gate

func _process(delta):
	# Move the gate along the X-axis
	global_transform.origin.x -= speed * delta

	# Remove the gate if it moves past the player (optional cleanup)
	if global_transform.origin.x < -10:  # Adjust threshold based on your scene
		reset_both_gates()

func _ready():
	# Find the MeshInstance3D node (update the path if needed)
	var mesh_instance = $MeshInstance3D

	# Check if there's an existing material
	var material = mesh_instance.material_override
	if material == null:
		material = StandardMaterial3D.new()  # Create a new material if none exists
		mesh_instance.material_override = material

	# Set the color dynamically based on is_positive
	if is_positive:
		material.albedo_color = Color(0, 1, 0)  # Green for positive
	else:
		material.albedo_color = Color(1, 0, 0)  # Red for negative

func update_speed(new_speed: float):
	# Update the gate's speed dynamically
	speed = new_speed

func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if the player interacts
		if is_positive:
			print("Positive effect applied!")
		else:
			print("Negative effect applied!")

		# Reset both gates to loop back
		reset_both_gates()

# Function to reset both gates' positions
func reset_both_gates():
	if partner_gate != null:
		# Randomize whether to swap sides
		var swap = randi() % 2 == 0  # 50% chance to swap sides
		if swap:
			# Swap the z-positions of this gate and its partner
			var temp_z = global_transform.origin.z
			global_transform.origin.z = partner_gate.global_transform.origin.z
			partner_gate.global_transform.origin.z = temp_z
			print("Gates swapped sides!")

		partner_gate.reset_gate_position()
	reset_gate_position()

# Function to reset this gate's position
func reset_gate_position():
	global_transform.origin.x += 40  # Move the gate back to its starting position
	print("Gate looped!")
